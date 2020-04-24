project('tomlc99', 'c', license: 'MIT')
pkg = import('pkgconfig')

toml = library('toml',
  ['toml.c', 'toml.h'],
  install: true
)
install_headers('toml.h')
toml_dep = declare_dependency(link_with: toml)

executable('toml_json', 'toml_json.c', link_with: toml)
executable('toml_cat',  'toml_cat.c',  link_with: toml)

pkg.generate(toml,
             name: meson.project_name(),
             description: 'tomlc99 - TOML parser in C99',
             url: 'https://github.com/cktan/tomlc99')
