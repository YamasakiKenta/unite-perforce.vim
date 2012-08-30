command! -complete=customlist,Pf_complate_have -nargs=1 PFFIND call perforce#pfFind(<f-args>) "{{{
function! Pf_complate_have(A,L,P) 
	"********************************************************************************
	" 補完 : perforce 上に存在するファイルを表示する
	"********************************************************************************
	let outs = split(system('p4 have //.../'.a:A.'...'), "\n")
	return map( copy(outs), "
				\ matchstr(v:val, '.*/\\zs.\\{-}\\ze\\#')
				\ ")
endfunction
