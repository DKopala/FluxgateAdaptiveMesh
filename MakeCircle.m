% function to make circle set
function [x_tab,y_tab,n]=MakeCircle(x_core,y_core,r, maxh)

  % Initialize result parameters
  n = round((2.*pi*r)./maxh);
  x_tab = [];
  y_tab = [];

  for i=1:n
     x_tab(i) = r.*cos((2.*pi*i)./n);
     y_tab(i) = r.*sin((2.*pi*i)./n);
  end

  x_tab += x_core;
  y_tab += y_core;

end
