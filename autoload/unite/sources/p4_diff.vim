function! unite#sources#p4_diff#define()
	return s:source
endfunction

let s:source = {
			\ 'name' : 'p4_diff',
			\ 'description' : '�t�@�C���̍����\��',
			\ }
function! s:source.gather_candidates(args, context) "{{{

	" �������Ȃ��ꍇ�́A�󔒂�ݒ肷��
	let args = len(a:args) ? a:args : ['']
	let args = perforce#get_trans_enspace(args)

	let outs = []
	for arg in args
		let outs += perforce#pfcmds('diff','',perforce#Get_kk(arg))
	endfor

	"let outs = map(copy(args), "perforce#pfcmds('diff','',perforce#Get_kk(v:val))")

	"echo outs
	"call input("")
	return perforce#get_source_diff_from_path(outs) 
endfunction "}}}
