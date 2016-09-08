;Fills ALOS image where there is shadow/layover effect using Landsat relationship

;This one uses the post/aggregation 100m ALOS int files which are in unites of power * 10000


PRO fill_alos, hh_array, hv_array, mask, ndvi

	;mask_index = where(((mask eq 0) or (mask eq 100) or (mask eq 150)), mask_count)

	;if (mask_count gt 0) then begin
	;	ndvi_ulong = ulong(ndvi[mask_index])
	;	hh_mask_fill = ndvi_ulong * 69UL - 5730UL
	;	hv_mask_fill = ndvi_ulong * 42UL - 3714UL

	;	index = where((hh_mask_fill lt 1000), hh_bad_count)
	;	if (hh_bad_count gt 0) then hh_mask_fill[index] = 1000
	;	index = where((hv_mask_fill lt 500), hv_bad_count)
	;	if (hv_bad_count gt 0) then hv_mask_fill[index] = 500

	;	hh_array[mask_index] = hh_mask_fill
	;	hv_array[mask_index] = hv_mask_fill
	;endif

	hh_index = where(hh_array gt 8000, hh_count)
	hv_index = where(hv_array gt 2000, hv_count)

	if (hh_count gt 0) then begin
		ndvi_ulong = ulong(ndvi[hh_index])
		hh_mask_fill = ndvi_ulong * 69UL - 5730UL
		index = where((hh_mask_fill lt 1000), hh_bad_count)
		if (hh_bad_count gt 0) then hh_mask_fill[index] = 1000
		;convert ndvi calculated DN to power
		hh_array[hh_index] = fix(dn2power(double(hh_mask_fill))*10000)
	endif

	if (hv_count gt 0) then begin
		ndvi_ulong = ulong(ndvi[hv_index])
		hv_mask_fill = ndvi_ulong * 42UL - 3714UL
		index = where((hv_mask_fill lt 500), hv_bad_count)
		if (hv_bad_count gt 0) then hv_mask_fill[index] = 500
		;convert ndvi calculated DN to power
		hv_array[hv_index] = fix(dn2power(double(hv_mask_fill))*10000)
	endif
		

END




PRO fill_image_100m, alos_hh_image, alos_hv_image, alos_mask, ndvi_image, out_hh_image, out_hv_image

	openr, alos_hh_lun, alos_hh_image, /get_lun
	openr, alos_hv_lun, alos_hv_image, /get_lun
	;openr, mask_lun, alos_mask, /get_lun
	openr, ndvi_lun, ndvi_image, /get_lun

	openw, out_hh_lun, out_hh_image, /get_lun
	openw, out_hv_lun, out_hv_image, /get_lun


	;ALOS images are assumed to be unsigned int
	;MODIS images are int
	;mask is byte

	;determine number of pixels

	infile_info = file_info(alos_hh_image)
	infile_size = infile_info.size

 	tot_pix = infile_size/2

  read_pix = tot_pix / 100

  alos_hh_line = intarr(read_pix)
  alos_hv_line = intarr(read_pix)
  mask_line = bytarr(read_pix)
	ndvi_line = bytarr(read_pix)
	out_line = fltarr(read_pix)

  for i=0, 99 do begin
    print, i
    readu, alos_hh_lun, alos_hh_line
    readu, alos_hv_lun, alos_hv_line
    ;readu, mask_lun, mask_line
		readu, ndvi_lun, ndvi_line

		fill_alos, alos_hh_line, alos_hv_line, mask_line, ndvi_line

		index = where(alos_hh_line lt 0, count)
		if (count gt 0) then alos_hh_line[index] = 10
		index = where(alos_hv_line lt 0, count)
		if (count gt 0) then alos_hv_line[index] = 10
		;out_line[*] = 10^((20*alog10(float(alos_hh_line)) - 83) * 0.1)
		writeu, out_hh_lun, alos_hh_line;out_line
		;out_line[*] = 10^((20*alog10(float(alos_hv_line)) - 83) * 0.1)
		writeu, out_hv_lun, alos_hv_line;out_line

  endfor

  remainder = tot_pix mod 100

  if (remainder gt 0) then begin
  	alos_hh_line = intarr(remainder)
  	alos_hv_line = intarr(remainder)
  	mask_line = bytarr(remainder)
		ndvi_line = bytarr(remainder)
		out_line = fltarr(remainder)


    readu, alos_hh_lun, alos_hh_line
    readu, alos_hv_lun, alos_hv_line
    ;readu, mask_lun, mask_line
		readu, ndvi_lun, ndvi_line
		
		fill_alos, alos_hh_line, alos_hv_line, mask_line, ndvi_line

		index = where(alos_hh_line lt 0, count)
		if (count gt 0) then alos_hh_line[index] = 10
		index = where(alos_hv_line lt 0, count)
		if (count gt 0) then alos_hv_line[index] = 10
		;out_line[*] = 10^((20*alog10(float(alos_hh_line)) - 83) * 0.1)
		writeu, out_hh_lun, alos_hh_line;out_line
		;out_line[*] = 10^((20*alog10(float(alos_hv_line)) - 83) * 0.1)
		writeu, out_hv_lun, alos_hv_line;out_line

  endif

  free_lun, alos_hh_lun, alos_hv_lun, ndvi_lun, out_hh_lun, out_hv_lun

END
