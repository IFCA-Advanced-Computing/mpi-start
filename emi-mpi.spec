#
# Spec for emi-mpi metapackage, just contains dependencies
# to other packages.
#
Summary: A EMI metapackage for MPI tools (mpi-start and yaim) 
Name: emi-mpi
Version: 1.0.2
Release: 1%{?dist}
License: GPLv2
Group: Development/Tools
URL: http://github.com/IFCA/mpi-start
# No source, since this is a metapackage
# Source: emi-mpi.tar.gz
BuildArch: noarch
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n) 

# Fields for transition from glite-mpi to emi-mpi 
Provides: glite-mpi = %{version}-%{release} 
Obsoletes: glite-mpi < %{version}-%{release} 

# metapackage dependencies
Requires: glite-yaim-mpi
Requires: mpi-start
AutoReqProv: yes

%description
EMI Metapackage for MPI tools (mpi-start and yaim-mpi).

%prep
# Nothing, this is a metapackage!

%build

%install
rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root)

%changelog
* Tue Feb 21 2012 Enol Fernandez <enolfc _AT_ ifca.unican.es> - 1.0.2-1%{?dist}
- New emi-mpi metapackage, obsoletes glite-mpi metapackage.
