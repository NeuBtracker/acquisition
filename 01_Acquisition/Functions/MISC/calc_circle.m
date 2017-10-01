function [centre, radius] = calc_circle(pt1, pt2, pt3)

delta_a = pt2 - pt1;
delta_b = pt3 - pt2;

ax_is_0 = abs(delta_a(1)) <= 0.000000001;
bx_is_0 = abs(delta_b(1)) <= 0.000000001;

% check whether both lines are vertical - collinear
if (ax_is_0 && bx_is_0)
    centre = [0 0];
    radius = -1;
    return
end

% make sure delta gradients are not vertical
% re-arrange points to change deltas
if (ax_is_0)
    [centre,radius] = calc_circle(pt1, pt3, pt2);
    return
end
if (bx_is_0)
    [centre,radius] = calc_circle(pt2, pt1, pt3);
    return
end

grad_a = delta_a(2) / delta_a(1);
grad_b = delta_b(2) / delta_b(1);

% check whether the given points are collinear
if (abs(grad_a-grad_b) <= 0.000000001)
    centre = [0 0];
    radius = -1;
    return
end

% swap grads and points if grad_a is 0
if abs(grad_a) <= 0.000000001
    tmp = grad_a;
    grad_a = grad_b;
    grad_b = tmp;
    tmp = pt1;
    pt1 = pt3;
    pt3 = tmp;
end

% calculate centre - where the lines perpendicular to the centre of
% segments a and b intersect.
centre(1) = ( grad_a*grad_b*(pt1(2)-pt3(2)) + grad_b*(pt1(1)+pt2(1)) - grad_a*(pt2(1)+pt3(1)) ) / (2*(grad_b-grad_a));
centre(2) = ((pt1(1)+pt2(1))/2 - centre(1)) / grad_a + (pt1(2)+pt2(2))/2;

% calculate radius
radius = norm(centre - pt1); 