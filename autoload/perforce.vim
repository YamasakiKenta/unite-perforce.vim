let s:save_cpo = &cpo
set cpo&vim

function! s:get_dd(str) "{{{
	" [2013-06-07 00:36]
	return len(a:str) ? '//...'.perforce#get_kk(a:str).'...' : ''
endfunction
"}}}

function! perforce#log_file(str) "{{{
	" [2013-06-07 00:37]
	" ********************************************************************************
	" @par  結果の出力を行う
	" @param[in]	str		表示する文字
	" ********************************************************************************
	"
	let strs = (type(a:str) == type([])) ? a:str :[a:str]

	for str in strs
		echom string(str)
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
		let outs = split(perforce#system(cmd), "\n")

		" 作業中のファイル
		if outs[0] =~ '\*pending\*' || chnum == 'default'
			let cmd = 'p4 opened -c '.chnum " args
			let files_ = split(perforce#system(cmd), "\n")
			call map(files_, "perforce#get#depot#from_opened(v:val)")

			let outs = []
			for file_ in files_ 
				let cmd = 'p4 diff -ds '.file_

				for tmp_out in split(perforce#system(cmd), "\n")
					if tmp_out =~ '- file(s) not opened for edit.'
						" 新規作成の場合
						let tmp_file = substitute(file_, '.*[\/]','','')
						let path     = perforce#get#path#from_depot_with_client('', file_)
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
		"}}}
	endfor
	"
	"データの出力 {{{
	let outs = []
	for data in datas 
		let outs += [data["files"]."\t\t".data["adds"]."\t".data["deleteds"]."\t".data["changeds"]]
	endfor

	call perforce#show(outs)
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
"
function! perforce#extend_dicts(key, ...) "{{{
	let rtns = []
	for dicts in a:000
		for dict in dicts
			call extend(rtns, dict[a:key])
		endfor
	endfor
	return rtns
endfunction
"}}}
"
function! perforce#show(str) "{{{
	" ********************************************************************************
	" @par  必ず別windows を表示する
	" ********************************************************************************
	call perforce#util#log_file('p4show', 1, a:str)
endfunction
"}}}

function! perforce#system_dict(port, cmd) "{{{
	" ********************************************************************************
	" @par スクリプト用のコマンドを実行する
	" @param[in]     
	" @return perforce の辞書型      
	" ********************************************************************************
	"
	let cmd = substitute(a:cmd, 'p4', 'p4 -s -G', '')
	call unite#print_message(cmd)
	let outputs = split(perforce#system(cmd), "\n")[:-2]

	if len(outputs) <= 0
		return []
	endif

	let start_key = matchstr(outputs[0], ' \zs[^ ]*')

	let i = 0
	let max = len(outputs)
	while ( i < max ) 
		let tmp = outputs[i]
		let outputs[i] = substitute(outputs[i], 
					\ 'info1: \(.\{-}\) \(.*\)',
					\ '''\1'':''\2'',',
					\ '')

		if tmp =~ 'info1: Description '
			while i+1 < max && outputs[i+1] !~ 'info1: client '
				unlet outputs[i+1]
				let max = max - 1
			endwhile
		endif

		let i = i + 1
	endwhile

	" 行数の取得
	let step = 1
	while(step < max && outputs[step] !~ "'".start_key."':")
		let step = step + 1
	endwhile

	" 少し修正
	for i in range(step, len(outputs)-1, step)
		let outputs[i] = '"port":a:port},{'.outputs[i]
	endfor

	let str = '[{'.join(outputs).'"port":a:port}]'

	let @+ = str
	let rtns = eval(str)

	return rtns
endfunction
"}}}

function! perforce#system(cmd)
	" [2013-07-06 10:38]
	if exists('s:exists_vimproc')
		let data = vimproc#system(a:cmd)
	else
		let data = system(a:cmd)
	endif
	return data
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

