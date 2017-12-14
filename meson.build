project('nightlight', 'vala', 'c')

i18n = import('i18n')

add_global_arguments('-DGETTEXT_PACKAGE="' + meson.project_name() + '-indicator"', language:'c')

shared_module(
    meson.project_name(),
    'src/Indicator.vala',
    'src/Widgets/PopoverWidget.vala',
    dependencies: [
        dependency('glib-2.0'),
        dependency('gobject-2.0'),
        dependency('granite'),
        dependency('gtk+-3.0'),
        dependency('wingpanel-2.0')
    ],
    install: true,
    install_dir : get_option('libdir') + '/wingpanel'
)

subdir('po')
