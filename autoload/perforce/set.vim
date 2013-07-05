let s:save_cpo = &cpo
set cpo&vim

function! s:pf_cmd_rtn_cmd_outs(cmd)
	" �R�}���h�Ǝ��s���ʂ�Ԃ�
	return extend([a:cmd], split(perforce#system(a:cmd), "\n"))
endfunction

function! perforce#set#PFCLIENTNAME(str) 
	return s:pf_cmd_rtn_cmd_outs('p4 set P4CLIENT='.a:str)
endfunction 

function! perforce#set#PFPORT(str) 
	return s:pf_cmd_rtn_cmd_outs('p4 set P4PORT='.a:str)
endfunction 

function! perforce#set#PFUSER(str) 
	return s:pf_cmd_rtn_cmd_outs('p4 set P4USER='.a:str)
endfunction 

let &cpo = s:save_cpo
unlet s:save_cpo
