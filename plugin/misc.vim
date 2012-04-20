fun! RakeReMigrate(env)
  let s:migration_version = split(expand('%:p:t'),'_')[0]
  exec 'Rake db:migrate:down VERSION='.s:migration_version.' RAILS_ENV='.a:env
  exec 'Rake db:migrate:up VERSION='.s:migration_version.' RAILS_ENV='.a:env
endfun

fun! RailsEnvs(A,L,P)
  return "test\nproduction\nfrontend\ndevelopment"
endfun


fun! GoSpec()
  let s:file_name = expand('%:p')
endfun


command! -nargs=1  -complete=custom,RailsEnvs Remigrate call RakeReMigrate( '<args>')

fun! HTMLLint()
  silent make %
  botright cw
  execute "normal \<c-l>"
endfun

au BufWritePost *.html call HTMLLint()

fun! CollectDojotypes()
  silent !cat % | grep dojoType | sed 's/^\s\+//g' > /tmp/htmlrequires
  new
  set bt=nofile
  silent r! cat /tmp/htmlrequires
  silent %s/dojoType=/dojo.require(/g
  silent %s/\n/);\r/g
  silent %!sort | uniq
endfun

fun! FindFile(name)
  silent exec '!echo "Search:" > /tmp/vim_find_file.ffind'
  silent e /tmp/vim_find_file.ffind
  set ft=ffind
  map <buffer> <cr> :call OpenFFile()<cr>
  map <buffer> <d> :call DeleteFFile()<cr>
  silent exec 'r!find /home/nicola/Projects/webmedapp/ -iname "'.a:name.'" -printf "\%f =>\%P\n" | grep -vE "~" | grep -vE "ria\/prebuild" | grep -vE "builds\/build_" | sort'
  silent w! /tmp/vim_find_file.ffind
endfun

fun! OpenFFile()
  let s:path = split(getline('.'),'=>')[1]
  exec 'e /home/nicola/w/m/'.s:path
endfun

fun! DeleteFFile()
  let s:path = split(getline('.'),'=>')[1]
  silent exec '!rm /home/nicola/w/m/'.s:path
  execute "normal I--"
endfun

command! -nargs=1 Ffind call FindFile( '<args>')

au BufNewFile,BufRead *.ffind set filetype=ffind

command! DojoTypes call CollectDojotypes()

fun! InflectorMethods(A,L,P)
  return "camelize\nclassify\nconstantize\ndasherize\ndemodulize\nforeign_key\nhumanize\ninflections\nordinalize\nparameterize\npluralize\nsingularize\ntableize\ntitleize\ntransliterate\nunderscore"
endfun

fun! Inflector(method) range
  let s:cmd = ":'<,'>!inflector ".a:method
  echo s:cmd
  exec s:cmd
endfun

command! -nargs=1  -range -complete=custom,InflectorMethods Inflector call Inflector( '<args>')

fun! SetRailsAlternate()
  let s:file = expand('%:p')
  if match(s:file,"_controller.rb") > -1
    let s:request_path = substitute(s:file,'controller.rb','spec.rb','')
    let s:request_path = substitute(s:request_path,'app/controllers','spec/requests','')
    let s:cmd = 'Rset b:alternate='.s:request_path
    exec s:cmd
  end

  if match(s:file,"spec/requests") > -1
    let s:controller_path = substitute(s:file,'spec.rb','controller.rb','')
    let s:controller_path = substitute(s:controller_path,'spec/requests','app/controllers','')
    let s:cmd = 'Rset b:alternate='.s:controller_path
    exec s:cmd
  end
endfun

au BufEnter *.rb
  \ if exists("b:rails_root") |
  \   call SetRailsAlternate() |
  \ endif |
