let s:save_cpo = &cpo
set cpo&vim

function! s:get_dd(str) "{{{
" [2013-06-07 00:36]
	return len(a:str) ? '//...'.perforce#get_kk(a:str).'...' : ''
endfunction
"}}}

function! perforce#get_tmp_file() "{{{
	" [2013-06-07 00:35]
	let g:perforce_tmp_dir  = get(g:, 'perforce_tmp_dir', '~/.perforce/' )
	let fname               = g:perforce_tmp_dir.'/tmpfile'

	if !isdirectory(g:perforce_tmp_dir)
		call mkdir(g:perforce_tmp_dir)
	endif

	return fname
endfunction
"}}}
function! perforce#LogFile(str) "{{{
	" [2013-06-07 00:37]
	" ********************************************************************************
	" @par  結果の出力を行う
	" @param[in]	str		表示する文字
	" ********************************************************************************
	"
	let strs = (type(a:str) == type([])) ? a:str :[a:str]

	for str in strs
		echo str
	endfor

endfunction
"}}}
function! perforce#matomeDiffs(...) "{{{
	" ********************************************************************************
	" @param[in]    ...  チェンジリスト
	" ********************************************************************************
" [2013-06-07 00:58]
	let datas = []

	for chnum in a:000
		" データの取得 {{{
		let cmd  = 'p4 describe -ds '.chnum
		let outs = split(system(cmd), "\n")

		" 作業中のファイル
		if outs[0] =~ '\*pending\*' || chnum == 'default'
			let cmd = 'p4 opened -c '.chnum
			let files_ = split(system(cmd), "\n")
			call map(files_, "perforce#get#depot#from_opened(v:val)")

			let outs = []
			for file_ in files_ 
				let cmd = 'p4 diff -ds '.file_

				for tmp_out in split(system(cmd), "\n")
					if tmp_out =~ '- file(s) not opened for edit.'
						" 新規作成の場合
						let tmp_file = substitute(file_, '.*[\/]','','')
						let path     = perforce#get#path#from_depot(file_)
						call extend(datas, {
									\ 'files' : tmp_file,
									\ 'adds'  : len(readfile(path)),
									\ 'changeds' : 0,
									\ 'deleteds' : 0, 
									\ })
					else
						call add(outs, tmp_out)
					endif
				endfor
			endfor


		endif

		let find_ = ' \(\d\+\) chunks \(\|\(\d\+\) / \)\(\d\+\) lines'
		for out in outs
			if out =~ "===="
				call add(datas, {
							\ 'files'    : matchstr(out,'.*/\zs.\{-}\ze#.*'),
							\ 'adds'     : 0,
							\ 'changeds' : 0,
							\ 'deleteds' : 0,
							\ })
			elseif out =~ 'add'.find_
				let datas[-1].adds = substitute(out,'add'.find_,'\4','')
			elseif out =~ 'deleted'.find_
				let datas[-1].deleteds = substitute(out,'deleted'.find_,'\4','')
			elseif out =~ 'changed'.find_
				let a = substitute(out,'changed'.find_,'\3','')
				let b = substitute(out,'changed'.find_,'\4','')
				let datas[-1].changeds = a > b ? a : b
			endif
		endfor
	endfor
	"}}}
	"
	"データの出力 {{{
	let outs = []
	for data in datas 
		let outs += [data["files"]."\t\t".data["adds"]."\t".data["deleteds"]."\t".data["changeds"]]
	endfor

	call perforce_2#show(outs)
	"}}}
endfunction
"}}}
function! perforce#pfFind(...) "{{{
" [2013-06-07 01:00]
	if a:0 == 0
		let str  = input('Find : ')
	else
		let str = a:1
	endif 

	if str !=# ""
		call unite#start([insert(map(split(str),"s:get_dd(v:val)"),'p4_have')])
	endif
endfunction
"}}}
function! perforce#unite_args(source) "{{{
	" [2013-06-07 01:01]
	"********************************************************************
	" @par          現在のファイル名を Unite に引数に渡します。
	" @param[in]	source	コマンド
	"********************************************************************

		" スペース対策
		let file_ = expand("%:p")
		let file_ = substitute(file_ , '\\' , '\/'  , 'g')
		let file_ = substitute(file_ , ':'  , '\\:' , 'g')
		let file_ = substitute(file_ , ' '  , '\\ ' , 'g')

		let cmd = 'Unite '.a:source.':'.file_
		exe cmd

endfunction
"}}}
function! perforce#get_kk(str) "{{{
	" [2013-06-07 01:11]
	return len(a:str) ? '"'.a:str.'"' : ''
endfunction
"}}}

let &cpo = s:save_cpo
unlet s:save_cpo

