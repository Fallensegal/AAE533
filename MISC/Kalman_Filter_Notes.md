# Notes in EKF

loading the datafile -> observations

initial mean
initial cov

mapping for process noise

propagation?

time-k
mean-k
cov-k

for all k
	pull out times you are not propagating
	propagate the mean and cov
	conver mean and cov to orbital elements
	save the sigma (sqrt of diag of cov)
	set the initial time to final tk


## How To Use The Filter

load data
inital mean
initial cov
process noise def
measurement noise

### initialize filter values
tk1
meank1
covk1
ctr -> Counter?

for k in length of time (going over all the time values)
	position at t
	velocity at t
	noiseless measure (RA, DEC)
	station position
	propagate to time
	
	calculate propagated mean and cov
	make sure cov is semi-pos definite
	
	% Compute measurements
	rhat -> extract from mean
	rhat_object -> rhat - r_station
	RAHat = acquire from rho from rhat (check for negative, if negative, add 2pi)
	DEhat = same thing as above
	zhat = [RAHat, DEhat]
	
	% Compute measurement jacobian
	Hk = "Honestly just check the screenshots"
	
	% Kalman Gain
	Ck = Cov * Hk
	Wk = Hk * Ck + Rk	(RK is measurement noise)
	Kk = Ck/Wk

	% Kalman Update
	mean_kalman = mkm + Kk*(zk - zhatk)
	cov_kalman = Pkm - Kk*Hk*Pkm ( make sure this is positive semi-definite )
	
	
