% Generate Constants from constant files

run("standard_gravitation_parameter.m");
run("time_constants.m")
save("constants.mat");
