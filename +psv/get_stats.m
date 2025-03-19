function [Mean, Std] = get_stats(object_info)

  area = zeros(length(object_info),1);

  for i=1:length(object_info)
    area(i,1) = object_info(i).Area;
  end

  Mean = mean(area);
  Std = std(area);

end
