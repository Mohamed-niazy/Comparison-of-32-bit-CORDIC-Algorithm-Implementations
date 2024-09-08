function [o_x,o_y,o_z]=cordic_f(func_,x,y,z,no_of_itr,word_length,frac_length,sign)
%% LUT for cos end tan_inv(1>>i)
q=0:no_of_itr;


res_tan=2.^-q;
cos_th=cos(atan(res_tan));
theta=fi(atan(res_tan),sign,word_length,frac_length);

%% cordic register initialization
z_o=fi(z,sign,word_length,frac_length);
temp=fi(x,sign,word_length,frac_length);

switch (func_)
    case 'cos_sin'
    x=fi(1/1.64676,sign,word_length,frac_length);
    y=fi(0,sign,word_length,frac_length);
    z=fi(z,sign,word_length,frac_length);
    if(z>=270)
    z=360-z;
    elseif(z>=180)
    z=z-180;
    elseif(z>=90)
    z=180-z;
    end
    case'tan_inv' 
    z=0;  
sign_x=(x<0);
sign_y=(y<0);
    if(~sign_x && sign_y)
    x=-y;
    y=temp;
    elseif(sign_x && sign_y)
    x=-x;
    y=-y;
    elseif(sign_x && ~sign_y)
    x=-y;
    y=-temp;
    end

%   case 'rotate_cw'
%     if(z>=270)
%     z=360-z;
%     x=y;
%     y=temp;
%     elseif(z>=180)
%     z=z-180;
%     elseif(z>=90)
%     z=180-z;
%     x=y;
%     y=temp ;
%     end
%   case 'rotate_acw'
% d(i)=-((-1)^(z(i)<0)); %rotating cordic depend on sign of z
% z(i+1)=z(i)+d(i)*theta(i)*180/pi;

end

%% cordic algorithm

for i=1:no_of_itr

switch (func_)
    case 'cos_sin'
d(i)=-((-1)^(z(i)<0)); %rotating cordic depend on sign of z
z(i+1)=z(i)+d(i)*theta(i)*180/pi;
    case'tan_inv' 
d(i)=((-1)^(y(i)<0)); %vectoring cordic depend on sign of y
z(i+1)=z(i)+d(i)*theta(i)*180/pi;
    case 'rotate_cw'
d(i)=((-1)^(z(i)<0)); %rotating cordic depend on sign of z
z(i+1)=z(i)-d(i)*theta(i)*180/pi;
  case 'rotate_acw'
d(i)=-((-1)^(z(i)<0)); %rotating cordic depend on sign of z
z(i+1)=z(i)+d(i)*theta(i)*180/pi;

end


x(i+1)=x(i)+y(i)*d(i)*2^(-i+1);
y(i+1)=y(i)-x(i)*d(i)*2^(-i+1);

end




switch (func_)
    case 'cos_sin'


    if(z_o>=270)
    o_x=x(no_of_itr);
    o_y=-y(no_of_itr);
    elseif(z_o>=180)
    o_x=-x(no_of_itr);
    o_y=-y(no_of_itr);
    elseif(z_o>=90)
    o_x=-x(no_of_itr);
    o_y=y(no_of_itr);
    else 
    o_x=x(no_of_itr);
    o_y=y(no_of_itr);
    end


    o_z=0;
    case'tan_inv' 
    o_x=x(no_of_itr)*fi(prod(cos_th(1:no_of_itr)),sign,word_length,frac_length);
    o_y=0;

     if(~sign_x && sign_y)
    o_z=z(no_of_itr)+270;
    elseif(sign_x && sign_y)
    o_z=z(no_of_itr)+180;
    elseif(sign_x && ~sign_y)
    o_z=z(no_of_itr)+90;
     else 
    o_z=z(no_of_itr);
    end
    case {'rotate_acw' ,'rotate_cw'}
    o_x=x(no_of_itr)*fi(prod(cos_th(1:no_of_itr)),sign,word_length,frac_length);
    o_y=y(no_of_itr)*fi(prod(cos_th(1:no_of_itr)),sign,word_length,frac_length);
    o_z=0;

end


