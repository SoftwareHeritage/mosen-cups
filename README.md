## puppet-cups module

## Important

After git tag 1.4.0_RC1 I have made a non-backwards compatible change to the way ppd_options and options parameters
work. If you want to use the old behavior, please use tag 1.4.0_RC1 or 1.3.0

## User Guide

### Overview

This type provides the ability to manage cups printers and options.

Limitations:

+ It currently does not support classes.
+ It currently does not set default printers.

### Installation

You can install the latest release version from the module forge by executing this command:

    puppet module install mosen-cups

You can also clone the source repository into your module path, but be aware that HEAD is sometimes broken.

### Examples

#### Basic

The most basic printer install possible:

    printer { "Basic_Printer":
        ensure      => present,
        uri         => "lpd://hostname/printer_a",
        description => "This is the printer description",
        ppd         => "/Library/Printers/PPDs/Printer.ppd", # OR
        model       => "drv:///sample.drv/okidata9.ppd", # Model from `lpinfo -m`
    }

- The uri identifies how you will connect to the printer. running `lpinfo -v` at the command line will give you some
valid uri prefixes.
- The description only appears in certain dialogs on linux and friends. On OSX the description is the actual name of
the printer.
- The ppd or model parameter specifies the "driver" to use with this printer. You should use `model` wherever available
because most driver software will install straight into the cups model directory. You can get a list of valid models by
running `lpinfo -m` at the command line.

Removing the printer "Basic_Printer" from the previous example:

    printer { "Basic_Printer":
        ensure      => absent,
    }

### Advanced

An example using almost every possible parameter:

    printer { "Extended_Printer":
        ensure       => present,
        uri          => "lpd://localhost/printer_a",
        description  => "This is the printer description",
        location     => "Main office",
        ppd          => "/Library/Printers/PPDs/Printer.ppd", # Full path to vendor PPD
        # OR
        model        => "", # A valid model, you can list these with lpinfo -m, this is usually what you would call a
                            # list of installed drivers.
        # OR
        interface    => "/path/to/system/v/interface/file", # Interface script run for this destination
        shared       => false, # Printer will be shared and published by CUPS
        error_policy => abort_job, # underscored version of error policy
        enabled      => true, # Enabled by default
        options      => { media => 'A4' }, # Hash of options ( name => value ), these are lpoptions, be aware that not
                                           # all applications will even use the lpoptions file.
        ppd_options  => { 'HPOption_Duplexer' => 'False' }, # Hash of vendor PPD options, set on creation.
    }

- To find valid ppd_options values for a printer, install it locally using the vendor supplied PPD and
run `lpoptions -p <dest> -l`. You can also read the PPD if that's your thing.
- Note that some options like `shared` and `error_policy` are parameters available at creation time only.

### Facts

The module provides access to one additional facter fact "printers", which provides a comma separated list of installed
printers.

For more information about printer options, models, and uri's, refer to the CUPS documentation.

### Bugs

Please submit any issues through Github issues as I don't have a dedicated project page for this module.

## Developer Guide

### OSX Specifics

#### Printer Presets

Each printer can have a set of options, normally presented in the print dialog, saved as a named preset.
Named presets are stored in property lists at the following location:

    ~/Library/Preferences/com.apple.print.custompresets._PRINTER_QUEUE_NAME_.plist

#### Default Printer

If you select "Last Used Printer", it will select the printer in:

    ~/Library/Preferences/org.cups.PrintingPrefs.plist

As the default printer.

If you want to set the default printer, you probably shouldn't use `lpoptions` because it only governs the default
when submitting jobs under certain circumstances.

#### Default Paper Size

Again, OSX doesn't respect lpoptions when you set default page size via `lpoptions` or `lpadmin`.
The file containing the actual default page size is:

    ~/Library/Preferences/com.apple.print.PrintingPrefs.plist

Under the plist key `DefaultPaperID`, which has a string that relates to a non-localised paper size. The PrintCore
framework seems to have these listed in a binary plist under OSX 10.8. You can dump some localised strings using

    /usr/libexec/plistbuddy -c "print" /System/Library/Frameworks/ApplicationServices.framework/Versions/A/Frameworks/PrintCore.framework/Versions/Current/Resources/English.lproj/Localizable.strings

#### Vendor PPD Options

The provider only alters PPD options on creation due to the way that `lpadmin` works. There seems to be no command line
interface for the direct modification of PPD files contained in `/etc/cups/ppd`. The CUPS web interface does however
provide the means to modify PPD options after the printer has been added.

### Contributing

You can issue a pull request and send me a message if you like, and I will consider taking the patch upstream :)

### Testing

The tests need a lot of improvement, but you can run them with RSpec in the typical way:

Make sure you have:

    rake

Install the necessary gems:

    gem install rspec

And run the tests from the root of the source code:

    rake test

#### Acceptance Tests

You can execute the beaker tests starting with:

    BEAKER_destroy=no bundle exec rspec spec/acceptance

And then re-use the provisioned guests with

    BEAKER_destroy=no BEAKER_provision=no bundle exec rspec spec/acceptance

Unset `BEAKER_destroy` after testing has finished or VM is dirty for the purposes of testing.

2015.02.21: Changed default vagrant boxes to VMWare Fusion boxes. I will keep VirtualBox nodesets but they will only
 be available optionally by using the `BEAKER_set={nodename}` environment variable.
Ditched puppetlabs' vagrant boxes since they weren't being updated and they are using vCloud anyway.


