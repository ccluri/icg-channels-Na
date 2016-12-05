TITLE Hippocampal HH channels
:
: Fast Na+ and K+ currents responsible for action potentials
: Iterative equations
:
: Equations modified by Traub, for Hippocampal Pyramidal cells, in:
: Traub & Miles, Neuronal Networks of the Hippocampus, Cambridge, 1991
:
: range variable vtraub adjust threshold
:
: Written by Alain Destexhe, Salk Institute, Aug 1992
:

INDEPENDENT {t FROM 0 TO 1 WITH 1 (ms)}

NEURON {
	SUFFIX hh2
	USEION na READ ena WRITE ina
	USEION k READ ek WRITE ik
	RANGE gnabar, gkbar, vtraub
	GLOBAL m_inf, h_inf, n_inf
	GLOBAL tau_m, tau_h, tau_n
	GLOBAL m_exp, h_exp, n_exp
}


UNITS {
	(mA) = (milliamp)
	(mV) = (millivolt)
}

PARAMETER {
	gnabar	= .003 	(mho/cm2)
	gkbar	= 0.0 	(mho/cm2)

	ena	= 50	(mV)
	ek	= -90	(mV)
	celsius = 36    (degC)
	dt              (ms)
	v               (mV)
	vtraub	= -63	(mV)
}

STATE {
	m h n
}

INITIAL {
	m = 0
	h = 0
	n = 0
}

ASSIGNED {
	ina	(mA/cm2)
	ik	(mA/cm2)
	il	(mA/cm2)
	m_inf
	h_inf
	n_inf
	tau_m
	tau_h
	tau_n
	m_exp
	h_exp
	n_exp
}


BREAKPOINT {
	SOLVE states
	ina = gnabar * m*m*m*h * (v - ena)
	ik  = gkbar * n*n*n*n * (v - ek)
}


:DERIVATIVE states {   : exact Hodgkin-Huxley equations
:	evaluate_fct(v)
:	m' = (m_inf - m) / tau_m
:	h' = (h_inf - h) / tau_h
:	n' = (n_inf - n) / tau_n
:}

PROCEDURE states() {	: exact when v held constant
	evaluate_fct(v)
	m = m + m_exp * (m_inf - m)
	h = h + h_exp * (h_inf - h)
	n = n + n_exp * (n_inf - n)
	VERBATIM
	return 0;
	ENDVERBATIM
}

UNITSOFF

PROCEDURE evaluate_fct(v(mV)) { LOCAL a,b,tadj,v2

	v2 = v - vtraub : convert to traub convention
	tadj = 3.0 ^ ((celsius-36)/ (10 (degC)) )

	a = 0.32 * (13-v2) / ( exp((13-v2)/4) - 1)
	b = 0.28 * (v2-40) / ( exp((v2-40)/5) - 1)
	tau_m = 1 / (a + b) / tadj
	m_inf = a * tau_m

	a = 0.128 * exp((17-v2)/18)
	b = 4 / ( 1 + exp((40-v2)/5) )
	tau_h = 1 / (a + b) / tadj
	h_inf = a * tau_h

	a = 0.032 * (15-v2) / ( exp((15-v2)/5) - 1)
	b = 0.5 * exp((10-v2)/40)
	tau_n = 1 / (a + b) / tadj
	n_inf = a * tau_n

	m_exp = 1 - exp(-dt/tau_m)
	h_exp = 1 - exp(-dt/tau_h)
	n_exp = 1 - exp(-dt/tau_n)
}

UNITSON
