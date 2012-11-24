function s:_head(func, lnum)
	return 'func='.a:func.', lnum='.a:lnum
endfunction

function s:exe_line(str)
	let str = 'echo '.s:_head('expand("<sfile>")', 'expand("<slnum>")').
				\ a:str
	return str
endfunction
