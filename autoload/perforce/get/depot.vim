
let s:save_cpo = &cpo
set cpo&vim

function! s:get_depot_from_where(str) 
	return split(a:str, '[^\\]\zs ')[1]
endfunction 

function! perforce#get#depot#from_have(str) 
	return matchstr(a:str,'.\{-}\ze#\d\+ - .*')
endfunction

function! perforce#get#depot#from_opened(str) 
	return substitute(a:str,'#.*','','')   " # ƒŠƒrƒWƒ‡ƒ“”Ô†‚Ìíœ
endfunction 

function! perforce#get#depot#from_path(str) 
	let out   = split(system('p4 where "'.a:str.'"'), "\n")[0]
	let depot =  s:get_depot_from_where(out)
	return depot 
endfunction 


let &cpo = s:save_cpo
unlet s:save_cpo
