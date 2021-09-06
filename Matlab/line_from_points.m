function [m, b] = line_from_points(x1, y1, x2, y2)
    m = (y2-y1) / (x2-x1);
    b = y1 - m*x1;
end

