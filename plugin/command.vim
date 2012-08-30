command! -complete=customlist,Pf_complate_have -nargs=1 PFFIND call perforce#pfFind(<f-args>) "{{{
function! Pf_complate_have(A,L,P) 
	"********************************************************************************
	" �⊮ : perforce ��ɑ��݂���t�@�C����\������
	"********************************************************************************
	let outs = split(system('p4 have //.../'.a:A.'...'), "\n")
	return map( copy(outs), "
				\ matchstr(v:val, '.*/\\zs.\\{-}\\ze\\#')
				\ ")
endfunction
