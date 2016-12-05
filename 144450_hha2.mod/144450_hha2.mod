TITLE HH channel that includes both a sodium and a delayed rectifier channel
: and accounts for sodium conductance attenuation
: Bartlett Mel-modified Hodgkin - Huxley conductances (after Ojvind et al.)
: Terrence Brannon-added attenuation 
: Yiota Poirazi-modified Kdr and Na threshold and time constants
: to make it more stable, 2000, poirazi@LNC.usc.edu
: Used in all BUT somatic and axon sections. The spike threshold is about -50 mV
:
: Modified to use CVode --Carl Gold 08/12/03
:  Updated by Maria Markaki  12/05/03

NEURON {
	SUFFIX hha2
	USEION na READ ena WRITE ina 
	USEION k READ ek WRITE ik
	NONSPECIFIC_CURRENT il
	RANGE gnabar, gkbar, gl, el,ik,ina
	RANGE ar2, vhalfs
	GLOBAL inf, tau, taumin
}

UNITS {
	(mA) = (milliamp)
	(mV) = (millivolt)
}


PARAMETER {   : parameters that can be entered when function is called in cell-setup
        a0r = 0.0003 (/ms)
        b0r = 0.0003 (/ms)
       : a0r = 0.0003 (ms)
        :b0r = 0.0003 (ms)
        zetar = 12    
	zetas = 12   
        gmr = 0.2   
	ar2 = 1.0               :initialized parameter for location-dependent
                                :Na-conductance attenuation, "s", (ar=1 -> zero attenuation)
:	taumin = 10   (ms)       :min activation time for "s" attenuation system
	taumin = 3   (ms)       : smax=10		(ms)
        vvs  = 2     (mV)       :slope for "s" attenuation system
        vhalfr = -60 (mV)       :half potential for "s" attenuation system
        vvh=-58		(mV) 
        gnabar = 1.0   (mho/cm2)  :initialized conductances
	gkbar = 0.0    (mho/cm2)  :actual values set in hoc code
	gl = 0       (mho/cm2)  : keep this to zero if using the NEURON pas mechanism
	el = -70.0   (mV)       :steady state 

}


ASSIGNED {
	celsius      (degC)
	v            (mV)
	ena          (mV)       :Na reversal potential (also reset in
	ek           (mV)       :K reversal potential  cell-setup.hoc)
	ina          (mA/cm2)
	ik           (mA/cm2)
	il           (mA/cm2)
	inf[4]
	tau[4]	     (ms)
}

STATE {
	m 
	h 
	n 
	s
}

INITIAL {                       : initialize the following parameter using states()
	rates(v,ar2)
	m = inf[0]
	h = inf[1]
	n = inf[2]
	s = inf[3]
}

BREAKPOINT {
	SOLVE states METHOD cnexp
	ina = gnabar*m*m*h*s*(v - ena) :Sodium current
	ik = gkbar*n*n*(v - ek)        :Potassium current
	il = gl*(v - el)               :leak current
}


DERIVATIVE states {
	rates(v,ar2)
	m' = (inf[0]-m)/tau[0]
	h' = (inf[1]-h)/tau[1]
	n' = (inf[2]-n)/tau[2]
	s' = (inf[3]-s)/tau[3]
}

PROCEDURE rates(v(mV),a2) {
	LOCAL tmp, c
	FROM i=0 TO 2 {
		tau[i] = vartau(v,i)
		inf[i] = varss(v,i)
	}
	tau[3] = betr(v)/(a0r*(1+alpr(v))) 
	if (tau[3]<taumin) {tau[3]=taumin} :s activation tau
	c = alpv(v)
	inf[3] = c+a2*(1-c) 
}


FUNCTION varss(v(mV), i) { :steady state values
	if (i==0) {
		varss = 1 / (1 + exp((v + 44)/(-3(mV)))) :Na activation
	}
	else if (i==1) {
		varss = 1 / (1 + exp((v + 49)/(3.5(mV))))  :Na inactivation
	}
	else if (i==2) {	
		varss = 1 / (1 + exp((v + 46.3)/(-3(mV)))) :K activation

	}
}


FUNCTION alpv(v(mV)) {
         alpv = 1/(1+exp((v-vvh)/vvs))
}

FUNCTION alpr(v(mV)) {       :used in "s" activation system tau
UNITSOFF
  alpr = exp(1.e-3*zetar*(v-vhalfr)*9.648e4/(8.315*(273.16+celsius))) 
UNITSON
}

FUNCTION betr(v(mV)) {       :used in "s" activation system tau
UNITSOFF
  betr = exp(1.e-3*zetar*gmr*(v-vhalfr)*9.648e4/(8.315*(273.16+celsius))) 
UNITSON
}

FUNCTION vartau(v(mV), i) (ms){ :estimate tau values
	LOCAL tmp
	if (i==0) {
	   vartau = 0.05(ms)      :Na activation tau
	}
	else if (i==1) {
           vartau = 1(ms)       :Na inactivation tau
        }
	else if (i==2) {
            vartau = 3.5(ms)      :K activation tau
       	}: else {
	  :   tmp =1* betr(v)/(a0r+b0r*alpr(v)) 
	   :  if (tmp<taumin) {tmp=taumin}
	 :    vartau = tmp      :s activation tau
       :}
}	















