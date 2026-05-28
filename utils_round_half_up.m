
function y = utils_round_half_up(x)
if mod(x,1) == 0.5
    y = floor(x) + 1;
else
    y = round(x);
end
end
``
