Function dn2power, dn
	return, 10D^((20D*alog10(dn)-83D)*0.1D)
End
