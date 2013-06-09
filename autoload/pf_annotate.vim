let s:save_cpo = &cpo
set cpo&vim

function! pf_annotate#gather_candidates(args, context, cmd) "{{{

	let depots = a:context.source__depots
	let client = a:context.source__client[0]

	let candidates = []
	for depot in depots 
		let datas = perforce#cmd#use_ports('p4 '.a:cmd.' '.perforce#get_kk(depot))

		for data in datas
			let lnum = 0
			for out in data.outs
				call add(candidates, {
							\ 'word'           : printf('%5d', lnum).' : '.out,
							\ 'action__depot'  : depot,
							\ 'action__out'    : out,
							\ 'action__cmd'    : a:cmd,
							\ 'action__client' : client,
							\ })
				let lnum += 1
			endfor
		endfor
	endfor

	return candidates
endfunction
"}}}

if exists('s:save_cpo')
	let &cpo = s:save_cpo
	unlet s:save_cpo
else
	set cpo&
endif
