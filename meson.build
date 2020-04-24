project('tomlc99', 'c', license: 'MIT')

toml = library('toml',
  ['toml.c', 'toml.h'],
  install: true
)
install_headers('toml.h')
toml_dep = declare_dependency(link_with: toml)

executable('toml_json', 'toml_json.c', link_with: toml)
executable('toml_cat',  'toml_cat.c',  link_with: toml)
