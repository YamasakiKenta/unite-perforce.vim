function! unite#sources#p4_diff#define()
	return s:source
endfunction

let s:source = {
			\ 'name' : 'p4_diff',
			\ 'description' : '�t�@�C���̍����\��',
			\ }
function! s:source.gather_candidates(args, context) "{{{

	" �������Ȃ��ꍇ�́A�󔒂�ݒ肷��
	if len(a:args) > 1
		let files = a:args
		let all_flg = 0
	else
		let files = []
		let all_flg = 1
	endif
	let files = perforce#get_trans_enspace(files)

	let rtns = []
	let outs = []
	for file in files
		if perforce#is_p4_have(file)
			let outs += perforce#pfcmds('diff','',perforce#Get_kk(file))
		else
			let rtns += perforce#get_source_file_from_path(file)
		endif
	endfor

	let rtns += perforce#get_source_diff_from_diff(outs) 

	" add �����t�@�C����ǉ�����
	if all_flg
		"let file = 
		
	endif
	return rtns
endfunction "}}}
