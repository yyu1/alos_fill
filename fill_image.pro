;Fills ALOS image where there is shadow/layover effect using MODIS relationship
Function hh_modis, djf, jja, mam, son

	return, 0.25 * ((-0.026194 + 0.000029471*djf) + (0.017528 + 0.000025374 * jja) + (-0.039718 + 0.000030951 * mam) + (0.0052936 + 0.000027285 * son))

END

Function hv_modis, djf, jja, mam, son

	return, 0.25 * ((-0.065008 + 0.000016193 * djf) + (-0.038894 + 0.000013619 * jja) + (-0.072585 + 0.000017027 * mam) + (-0.043472 + 0.000014338 * son))

END



PRO fill_image, alos_image, alos_mask, djf, mam, jja, son, out_image, IS_HH = hh_flag

	openr, alos_lun, alos_image, /get_lun
	openr, mask_lun, alos_mask, /get_lun
	openr, djf_lun, djf, /get_lun
	openr, mam_lun, mam, /get_lun
	openr, jja_lun, jja, /get_lun
	openr, son_lun, son, /get_lun

	openw, out_lun, out_image, /get_lun


	;ALOS images are assumed to be unsigned int
	;MODIS images are int
	;mask is byte

	;determine number of pixels

	infile_info = file_info(alos_image)
	infile_size = infile_info.size

 	tot_pix = infile_size/2

  read_pix = tot_pix / 100

  alos_line = uintarr(read_pix)
  mask_line = bytarr(read_pix)
  djf_line = intarr(read_pix)
	mam_line = intarr(read_pix)
	jja_line = intarr(read_pix)
	son_line = intarr(read_pix)
	out_line = fltarr(read_pix)

  for i=0, 99 do begin
    print, i
    readu, alos_lun, alos_line
    readu, mask_lun, mask_line
		readu, djf_lun, djf_line
		readu, mam_lun, mam_line
		readu, jja_lun, jja_line
		readu, son_lun, son_line


		out_line[*] = 10^((20*alog10(float(alos_line)) - 83) * 0.1)
    index = where((mask_line eq 100) or (mask_line eq 150), count)

    if (count gt 0) then begin
			if (keyword_set(hh_flag)) then begin
				out_line[index] = hh_modis(djf_line[index], jja_line[index], mam_line[index], son_line[index])
			endif else begin
				out_line[index] = hv_modis(djf_line[index], jja_line[index], mam_line[index], son_line[index])
			endelse
			
    endif

		writeu, out_lun, out_line
  endfor

  remainder = tot_pix mod 100

  if (remainder gt 0) then begin
 		alos_line = uintarr(remainder)
  	mask_line = bytarr(remainder)
  	djf_line = intarr(remainder)
  	mam_line = intarr(remainder)
  	jja_line = intarr(remainder)
  	son_line = intarr(remainder)
  	out_line = fltarr(remainder)

    readu, alos_lun, alos_line
    readu, mask_lun, mask_line
		readu, djf_lun, djf_line
		readu, mam_lun, mam_line
		readu, jja_lun, jja_line
		readu, son_lun, son_line

		out_line[*] = 10^((20*alog10(float(alos_line)) - 83) * 0.1)
    index = where((mask_line eq 100) or (mask_line eq 150), count)

    if (count gt 0) then begin
			if (keyword_set(hh_flag)) then begin
				out_line[index] = hh_modis(djf_line[index], jja_line[index], mam_line[index], son_line[index])
			endif else begin
				out_line[index] = hv_modis(djf_line[index], jja_line[index], mam_line[index], son_line[index])
			endelse
			
    endif

		writeu, out_lun, out_line
  endif

  free_lun, alos_lun, mask_lun, djf_lun, mam_lun, jja_lun, son_lun, out_lun

END
