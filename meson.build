project(
    'tomlc99', 'c',
    meson_version: '>= 0.47.0',
    version: 'v1.0',
    license: 'MIT',
    default_options: [
        'warning_level=2',
        'c_std=c99',
    ],
)

toml_sources = ['toml.c']
toml_headers = ['toml.h']

libtoml = library('toml',
    sources: toml_sources,
    install: true,
    version: '1.0',
)

install_headers(toml_headers)

libtoml_dep = declare_dependency(
    include_directories: include_directories('.'),
    link_with: libtoml,
)

pkg = import('pkgconfig')
pkg.generate(libtoml,
    filebase: meson.project_name(),
    name: meson.project_name(),
    version: meson.project_version(),
    description: 'TOML parser in c99; v1.0 compliant',
    url: 'https://github.com/cktan/tomlc99',
)
