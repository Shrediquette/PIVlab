function correlation_demo(Action)
% PIV cross-correlation demo
% C. Poelma (2009-2011); c.poelma@tudelft.nl
% GUI by P. van der Baan; p.vanderbaan@tudelft.nl
% PIV course DLR (Goettingen) and PIV course JMBC (Delft)

FigWidth   = 1270; % max 1270 @ 1280 pixels screenwidth
FigHeight  = 582; % max 940 @ 1024 pixels screenheigth

if nargin==0
    fi = figure(1);
    ScreenSize = get(0, 'ScreenSize');
    HorAlign   = (ScreenSize(3) - FigWidth) / 2;
    VertAlign  = (ScreenSize(4) - FigHeight) / 2 - 7;
    set(fi, 'position', [HorAlign VertAlign FigWidth FigHeight], 'Name', 'PIV_Demo', 'NumberTitle', 'off', 'Resize', 'on', 'Toolbar', 'none','DeleteFcn','PIV_Demo(''Close'')');
    fr=uipanel('Parent', fi, 'position', [1/FigWidth, 1/FigHeight, 140/FigWidth, (FigHeight-2)/FigHeight]);
    
    uicontrol('Parent', fr, 'Style', 'Text'        ,'position',[  5, 365,130, 15],'String','Number of Particles','horizontalalignment','left');
    uicontrol('Parent', fr, 'Style', 'Edit'        ,'position',[  5, 345,130, 20],'tag','n','String','128');
    uicontrol('Parent', fr, 'Style', 'Text'        ,'position',[  5, 325,130, 15],'String','Horizontal displacement','horizontalalignment','left');
    uicontrol('Parent', fr, 'Style', 'Edit'        ,'position',[  5, 305,130, 20],'tag','Vx','String','4');
    uicontrol('Parent', fr, 'Style', 'Text'        ,'position',[  5, 285,130, 15],'String','Vertical displacement','horizontalalignment','left');
    uicontrol('Parent', fr, 'Style', 'Edit'        ,'position',[  5, 265,130, 20],'tag','Vy','String','0');
    uicontrol('Parent', fr, 'Style', 'Text'        ,'position',[  5, 245,130, 15],'String','Particle size','horizontalalignment','left');
    uicontrol('Parent', fr, 'Style', 'Edit'        ,'position',[  5, 225,130, 20],'tag','psize','String','1');
    uicontrol('Parent', fr, 'Style', 'Text'        ,'position',[  5, 205,130, 15],'String','Interrogation Area Size','horizontalalignment','left');
    uicontrol('Parent', fr, 'Style', 'Edit'        ,'position',[  5, 185,130, 20],'tag','iasize','String','32');
    uicontrol('Parent', fr, 'Style', 'Text'        ,'position',[  5, 165,130, 15],'String','Noise Count','horizontalalignment','left');
    uicontrol('Parent', fr, 'Style', 'Edit'        ,'position',[  5, 145,130, 20],'tag','Noise','String','0');
    uicontrol('Parent', fr, 'Style', 'Text'        ,'position',[  5, 125,130, 15],'String','Out of plane loss','horizontalalignment','left');
    uicontrol('Parent', fr, 'Style', 'Edit'        ,'position',[  5, 105,130, 20],'tag','Loss','String','0');
    uicontrol('Parent', fr, 'Style', 'Checkbox'    ,'position',[  5, 85, 130, 20],'tag','Reflection','String','Add Reflection','value',0);
    uicontrol('Parent', fr, 'Style', 'Checkbox'    ,'position',[  5, 65, 130, 20],'tag','Gradient','String','Add Gradient','value',0);
    uicontrol('Parent', fr, 'Style', 'Checkbox'    ,'position',[  5, 45, 130, 20],'tag','PreShift','String','Add Preshift','value',0);
    uicontrol('Parent', fr, 'Style', 'Pushbutton'  ,'position',[  5, 25, 130, 20],'tag','Start','String','Start','callback','PIV_Demo(''Start'')');
    uicontrol('Parent', fr, 'Style', 'Togglebutton','position',[  5,  5, 130, 20],'tag','Stop','String','Stop');
    axes('position',[ (140+ 40)/FigWidth,                     25/FigHeight, 0.33*(FigWidth-270)/FigWidth, (FigHeight-70)/FigHeight],'Tag', 'a1');
    axes('position',[ (140+ 80+0.33*(FigWidth-270))/FigWidth, 25/FigHeight, 0.33*(FigWidth-270)/FigWidth, (FigHeight-70)/FigHeight],'Tag', 'a2');
    axes('position',[ (140+120+0.66*(FigWidth-270))/FigWidth, 25/FigHeight, 0.33*(FigWidth-270)/FigWidth, (FigHeight-70)/FigHeight],'Tag', 'a3');
    
else
    switch Action
        case 'Start'
            set(findobj('tag','n'),'enable','off')
            set(findobj('tag','Vx'),'enable','off')
            set(findobj('tag','Vy'),'enable','off')
            set(findobj('tag','psize'),'enable','off')
            set(findobj('tag','iasize'),'enable','off')
            set(findobj('tag','Noise'),'enable','off')
            set(findobj('tag','Loss'),'enable','off')
            set(findobj('tag','Reflection'),'enable','off')
            set(findobj('tag','Gradient'),'enable','off')
            set(findobj('tag','PreShift'),'enable','off')
            
            a1=findobj('tag','a1');
            a2=findobj('tag','a2');
            a3=findobj('tag','a3');
            
            %colormap(1-gray) % invert images for clarity
            
            imsize = 100;
            
            n = str2double(get(findobj('tag','n'),'string')); % number of particles
            vx =str2double(get(findobj('tag','Vx'),'string')); % horizontal displacement (pixels)
            vy = str2double(get(findobj('tag','Vy'),'string')); % vertical displacement
            psize = str2double(get(findobj('tag','psize'),'string'));   % 1 is normal, 10 is large
            iasize = str2double(get(findobj('tag','iasize'),'string')); % interrogation area size
            noise_count = str2double(get(findobj('tag','Noise'),'string'));% 128
            out_of_plane_loss = str2double(get(findobj('tag','Loss'),'string')); % fraction of particle pair loss due to out-of-plane motion
            reflection = get(findobj('tag','Reflection'),'value'); % add a reflection
            gradient_effect = get(findobj('tag','Gradient'),'value'); % add gradient (smears correlation peak)
            preshift = get(findobj('tag','PreShift'),'value'); % add pre-shift to "follow" particles
            
            x0 = rand(n,1).*imsize;
            y0 = rand(n,1).*imsize;
            
            maxint = 256;
            
            xr = 1:imsize;
            yr = 1:imsize;
            
            I = zeros(imsize,imsize);
            I1 = I;
            I2 = I;
            
            [xr,yr] = meshgrid(xr,yr);
            
            steps = 1000;
            
            corval(1:steps) = 0;
            
            %%%%%%%%%%%%%%
            
            Irefl = I;
            for k = 1:(imsize-1);
                Irefl(round(71-k./5),k) = 128;
                Irefl(round(72-k./5),k) = 128;
            end
            
            for t = 1:steps
                I = zeros(imsize,imsize);
                
                I1 = I2;
                
                for i = 1:n;
                    xp = x0(i);
                    yp = y0(i);
                    dist = (xr-xp).^2 + (yr-yp).^2;
                    Ip = 255.*exp(-dist/psize);
                    I = I + Ip;
                end
                
                I(I>maxint) = maxint;
                
                if ~gradient_effect
                    x0 = x0 + vx;
                else
                    x0 = x0 + vx.*(y0-imsize/2)./10;
                end
                
                nv = x0>imsize;
                for k = find(nv==1);
                    x0(k) = x0(k)-imsize;
                end
                
                nv = x0<0;
                for k = find(nv==1);
                    x0(k) = x0(k)+imsize;
                end
                
                perc_loss = rand(n,1);
                
                nv = perc_loss < out_of_plane_loss;
                
                xnew = rand(n,1).*imsize;
                ynew = rand(n,1).*imsize;
                
                x0(nv) = xnew(nv);
                y0(nv) = ynew(nv);
                
                I2 = I;
                
                iar = -(iasize/2-1):(iasize/2);
                
                if reflection
                    I1 = I1 + Irefl;
                    I2 = I2 + Irefl;
                end
                
                I1 = I1 + rand(imsize,imsize).*noise_count; % add some noise to the images
                I2 = I2 + rand(imsize,imsize).*noise_count;
                
                if ~preshift
                    ia1 = I1(imsize/2+iar,imsize/2+iar); % cut out first IA without shift
                else
                    ia1 = I1(imsize/2+iar,imsize/2+iar-vx); % cut out first IA with shift
                end
                
                ia2 = I2(imsize/2+iar,imsize/2+iar); % cut out second IA
                
                Itemp = I1; % visualize int. area by adding a constant value
                Itemp(imsize/2+iar,imsize/2+iar) = Itemp(imsize/2+iar,imsize/2+iar) + 128;
                
                Itemp2 = I2; % visualize int. area
                Itemp2(imsize/2+iar,imsize/2+iar) = Itemp2(imsize/2+iar,imsize/2+iar) + 128;
                
                
                ia1 = ia1-mean2(ia1);
                ia2 = ia2-mean2(ia2);
                
                %xc = fftshift(ifft2(fft2(ia2).*conj(fft2(ia1)))); % no zero padding
                %ac = fftshift(ifft2(fft2(ia1).*conj(fft2(ia1))));
                xc = fftshift(ifft2(fft2(ia2,iasize*2,iasize*2).*conj(fft2(ia1,iasize*2,iasize*2)))); % with zero padding
                ac = fftshift(ifft2(fft2(ia1,iasize*2,iasize*2).*conj(fft2(ia1,iasize*2,iasize*2))));
                
                mac = max(ac(:)); % get height of highest peak
                
                axes(a1)
                imagesc(Itemp);
                colormap(gray)
                h1 =title(['IA 1: ' num2str(iasize) ' ppp: ' num2str(n./imsize.^2) ' psize: ' num2str(psize) ' dx: ' num2str(vx)]);
                set(h1,'FontSize',floor(0.0135*FigWidth-1.16))
                set(a1,'tag','a1')
                axes(a2)
                imagesc(Itemp2);
                colormap(gray)
                h2 = title(['IA 2: ' num2str(iasize) ' ppp: ' num2str(n./imsize.^2) ' psize: ' num2str(psize) ' dx: ' num2str(vx)]);
                set(h2,'FontSize',floor(0.0135*FigWidth-1.16))
                set(a2,'tag','a2')
                axes(a3)
                imagesc(2.*(iar-1)+0.5,2.*(iar-1)+0.5,xc./mac,[-0.1 0.8]);
                colormap(gray)
                corval(t) = max(xc(:))./mac;
                cv = mean(corval(2:t));
                h3 = title(['max cor.: ' num2str(cv)]);
                set(h3,'FontSize',floor(0.0235*FigWidth-1.16))
                hold on
                plot(vx,vy,'y.')
                line([-iasize*2 iasize*2],[0 0],'linestyle',':','color','w');
                line([0 0],[-iasize*2 iasize*2],'linestyle',':','color','w');
                set(gcf,'color','w')
                hold off
                set(a3,'tag','a3')
                drawnow
                pause(0.01)
                
                %if t>1
                %    M(t-1) = getframe(gcf);
                %end
                Stop=get(findobj('tag','Stop'),'value');
                if Stop
                    set(findobj('tag','n'),'enable','on')
                    set(findobj('tag','Vx'),'enable','on')
                    set(findobj('tag','Vy'),'enable','on')
                    set(findobj('tag','psize'),'enable','on')
                    set(findobj('tag','iasize'),'enable','on')
                    set(findobj('tag','Noise'),'enable','on')
                    set(findobj('tag','Loss'),'enable','on')
                    set(findobj('tag','Reflection'),'enable','on')
                    set(findobj('tag','Gradient'),'enable','on')
                    set(findobj('tag','PreShift'),'enable','on')
                    set(findobj('tag','Stop'),'value',0);
                    break
                end
                
            end
        case 'Close'
            close all
            clear all
            clc
    end
end