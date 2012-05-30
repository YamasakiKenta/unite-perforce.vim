function! unite#sources#p4_diff#define()
	return s:source
endfunction

let s:source = {
			\ 'name' : 'p4_diff',
			\ 'description' : 'ファイルの差分表示',
			\ }
function! s:source.gather_candidates(args, context) "{{{

	" 引数がない場合は、空白を設定する
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
