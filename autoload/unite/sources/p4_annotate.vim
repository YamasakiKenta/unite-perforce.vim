let s:save_cpo = &cpo
set cpo&vim

function! unite#sources#p4_annotate#define()
	return [ 
				\ s:source__p4_annotate,
				\ s:source__p4_annotate_ai,
				\ ]
endfunction

function! s:get_revnum_from_annotate(str) "{{{
	return substitute(a:str,'^\(\d\+\).*','\1','')
endfunction 
"}}}
function! s:get_chnum_from_annotate(str) "{{{
	let low  = substitute(a:str, '\(\d\+\)-\(\d\+\):.*', '\1', '')
	let high = substitute(a:str, '\(\d\+\)-\(\d\+\):.*', '\2', '')

	return {
				\ 'low' : low,
				\ 'high' : high,
				\ }
endfunction 
"}}}

let s:source__p4_annotate = {
			\ 'name' : 'p4_annotate',
			\ 'description' : '各行にリビジョン番号を表示',
			\ 'hooks' : {},
			\ }
let s:source__p4_annotate.hooks.on_init = function('perforce#get_filename_for_unite')
function! s:source__p4_annotate.gather_candidates(args, context) "{{{

	let depots = a:context.source__depots

	let candidates = []
	let lnum = 0
	for depot in depots 
		let outs = perforce#cmd#base('annotate','',perforce#common#get_kk(depot)).outs

		for out in outs
		let candidates += map( [out], "{
					\ 'word' : lnum.' : '.v:val,
					\ 'kind' : 'k_p4_filelog',
					\ 'action__depot' : depot,
					\ 'action__revnum' : s:get_revnum_from_annotate(v:val),
					\ }")
		let lnum += 1
	endfor

	return candidates
endfunction "}}}

let s:source__p4_annotate_ai = {
			\ 'name' : 'p4_annotate_ai',
			\ 'description' : '各行にチェンジリスト番号を表示 ( 全て )',
			\ 'hooks' : {},
			\ }
let s:source__p4_annotate_ai.hooks.on_init = function('perforce#get_filename_for_unite')
function! s:source__p4_annotate_ai.gather_candidates(args, context) "{{{

	let depots = a:context.source__depots

	let candidates = []
	for depot in depots 

		let outs = perforce#cmd#base('annotate','','-ai '.perforce#common#get_kk(depot)).outs

		let candidates += map( outs, "{
					\ 'word' : v:val,
					\ 'kind' : 'k_p4_filelog',
					\ 'action__depot' : depot,
					\ 'action__chnum' : s:get_chnum_from_annotate(v:val),
					\ }")
	endfor

	return candidates
endfunction "}}}

if 1
	call unite#define_source(s:source__p4_annotate_ai)
	call unite#define_source(s:source__p4_annotate)
endif

let &cpo = s:save_cpo
unlet s:save_cpo

