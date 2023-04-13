%Parallel computing performance analysis including post processing.

%% Add PIVlab path so we can access functions
addpath('C:\Users\trash\Documents\MATLAB\PIVlab')

%% Settings
image_sizes=[600 1200 2500];
cores_to_use=[1 3  5 7 8];
nr_of_image_pairs=50;

%% 1: generate piv images with different sizes
for image_size=image_sizes
	disp(['         Image size:         ' num2str(image_size) ' px'])
	mkdir (num2str(image_size));
	generate_images(fullfile(pwd,num2str(image_size)),nr_of_image_pairs,image_size)
end

%% 2: analyze these images with different amount of cores
idx2=1;
calculation_times=zeros(numel(image_sizes),numel(cores_to_use));
for cores=cores_to_use
	idx=1;
	for image_size=image_sizes
		calculation_times(idx,idx2)=PIVlab_commandline_parallel_speed(fullfile(pwd,num2str(image_size)),cores);
		idx=idx+1;
	end
	idx2=idx2+1;
end

%% 3: Plot the results
%rows=image size
%cols=num of cores
figure;
semilogy(calculation_times','linewidth',2)
legend(compose('%d px',image_sizes))
grid on
xlabel('nr of cores')
set(gca,'xticklabel',compose('%d cores',cores_to_use))
ylabel('processing time')

