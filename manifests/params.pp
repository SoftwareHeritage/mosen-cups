# Various default parmeters
class cups::params {
  $package_ensure                   = present
  $package_name                     = 'cups'
  $package_install_options          = undef

  $devel_package_ensure             = undef
  $devel_package_name               = "${package_name}-devel"
  $devel_package_install_options    = undef

  $service_ensure                   = 'running'
  $service_enabled                  = true
  $service_name                     = 'cups'

  $cups_lpd_enable                  = false
  $cups_lpd_ensure                  = 'running'
  $package_cups_lpd                 = 'cups-lpd'
  $package_cups_lpd_install_options = undef
  $config_file                      = 'puppet:///modules/cups/cups-lpd'
}
