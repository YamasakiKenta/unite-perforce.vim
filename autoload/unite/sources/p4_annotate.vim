function! unite#sources#p4_annotate#define()
	return s:source
endfunction

let s:source = {
			\ 'name' : 'p4_annotate',
			\ 'description' : '�e�s�Ƀ��r�W�����ԍ���\��',
			\ 'hooks' : {},
			\ }

" [ ] - �����ɂ���
let s:source.hooks.on_init = function('perforce#GetFileNameForUnite')
function! s:getRevisionNumFromAnnotate(str) "{{{
	let rtn = substitute(a:str,'^\(\d\+\).*','\1','')
	return rtn
endfunction "}}}
function! s:source.gather_candidates(args, context) "{{{
	let path = a:context.source__path
	let outs = perforce#cmds('annotate '.perforce#Get_kk(path))
	let candidates = map( outs, "{
				\ 'word' : v:val,
				\ 'kind' : 'k_p4_filelog',
				\ 'action__path' : path,
				\ 'action__revnum' : <SID>getRevisionNumFromAnnotate(v:val),
				\ }")
	return candidates
endfunction "}}}
