let s:save_cpo = &cpo
set cpo&vim

function! s:open_files(files) "{{{
	let files_ = a:files

	" �����̃t�@�C����ʃ^�O�ŊJ��
	exe 'tabe' files_[0]
	
	for file_ in files_[1:]
		exe 'sp' file_
	endfor
endfunction "}}}
function! s:open_bufnrs(bufnrs) "{{{
	let bufnrs = a:bufnrs
	tabe
	" �ŏ��̉�ʂ̍X�V
	exe 'b' bufnrs[0]

	" 2��ʖڂ���́A��������
	for bufnr in bufnrs[1:]
		exe 'sb' bufnr
	endfor	
endfunction "}}}
function! s:copy_wins() "{{{
	let bufnrs = []
	windo let bufnrs += [bufnr("%")]
	call s:open_bufrnrs(bufnrs)
endfunction "}}}
function! s:open_lines(datas) "{{{
	let datas = a:datas
	tabe

	" �ŏ��̉�ʂ̍X�V
	exe 'b' datas[0]

	" 2��ʖڂ���́A��������
	for lines in datas[1:]
		sp
		call append(0, lines)
	endfor	
endfunction "}}}

let &cpo = s:save_cpo
unlet s:save_cpo
