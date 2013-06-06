
let s:save_cpo = &cpo
set cpo&vim

function! s:get_depot_from_where(str) 
	" [2013-06-07 02:28]
	return split(a:str, '[^\\]\zs ')[1]
endfunction 

function! perforce#get#depot#from_opened(str) 
	" [2013-06-07 02:28]
	return substitute(a:str,'#.*','','')   " # ƒŠƒrƒWƒ‡ƒ“”Ô†‚Ìíœ
endfunction 

function! perforce#get#depot#from_path(str) 
	" [2013-06-07 02:28]
	let out   = split(system('p4 where "'.a:str.'"'), "\n")[0]
	let depot =  s:get_depot_from_where(out)
	return depot 
endfunction 


let &cpo = s:save_cpo
unlet s:save_cpo
