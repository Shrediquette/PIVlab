function metadata = extractOptronisMetadata(imageData)
%enable counter information
%{
OPTRONIS_settings.Source.CounterInformation = 'On';
pause(0.1)
OPTRONIS_settings.Source.CounterInformation
%}
if strcmpi(class(imageData),'uint16')
    bitMode = 10;
elseif strcmpi(class(imageData),'uint8')
    bitMode = 8;
else
    error('unsupported file format (must be 8 or 10 bit Optronis image)')
end
switch bitMode
    case 8
        %{
Counting starts at 1
Pixel 1 contains bits 16–9 of the image counter
Pixel 2 contains bits 8–1 of the image counter
Pixel 3 contains bits 24–17 of the microsecond counter
Pixel 4 contains bits 16–9 of the microsecond counter
Pixel 5 contains bits 8–1 of the microsecond counter
        %}
        headerPixels= uint8(imageData(1,1:5));
        imageCounter=uint16(0);
        for i=16:-1:9
            imageCounter=bitset(imageCounter,i,bitget(headerPixels(1),i-8));
        end
        for i=8:-1:1
            imageCounter=bitset(imageCounter,i,bitget(headerPixels(2),i));
        end
        microsecCounter=uint32(0);
        for i=24:-1:17
            microsecCounter=bitset(microsecCounter,i,bitget(headerPixels(3),i-16));
        end
        for i=16:-1:9
            microsecCounter=bitset(microsecCounter,i,bitget(headerPixels(4),i-8));
        end
        for i=8:-1:1
            microsecCounter=bitset(microsecCounter,i,bitget(headerPixels(5),i));
        end
    case 10
        %{
Counting starts at 1 in this description
Pixel 1 contains bits 16..7 of the image counter
Pixel 2 contains bits 6..1 of the image counter and bits 24..21 of the microsecond counter
Pixel 3 contains bits 20..11 of the microsecond counter
Pixel 4 contains bits 10..1 of the microsecond counter
        %}
        headerPixels= uint16(imageData(1,1:4))/64;
        imageCounter=uint16(0);
        for i=16:-1:7
            imageCounter=bitset(imageCounter,i,bitget(headerPixels(1),i-6));
        end
        for i=6:-1:1
            imageCounter=bitset(imageCounter,i,bitget(headerPixels(2),i+4));
        end
        microsecCounter=uint32(0);
        for i=24:-1:21
            microsecCounter=bitset(microsecCounter,i,bitget(headerPixels(2),i-20));
        end
        for i=20:-1:11
            microsecCounter=bitset(microsecCounter,i,bitget(headerPixels(3),i-10));
        end
        for i=10:-1:1
            microsecCounter=bitset(microsecCounter,i,bitget(headerPixels(4),i));
        end
    otherwise
        error('Invalid bit mode. Use 8 or 10.');
end
metadata = struct( ...
    'ImageCounter', imageCounter, ...
    'MicrosecondCounter', microsecCounter ...
    );
end