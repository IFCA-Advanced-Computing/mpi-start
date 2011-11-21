#
# Spec for glite-mpi metapackage, just contains dependencies
# to other packages.
#
Summary: Metapackage for glite-MPI
Name: glite-mpi
Version: 1.0.1
Release: 1%{?dist}
License: GPLv2
Group: Development/Tools
URL: http://devel.ifca.es/mpi-start/
Source: glite-mpi-%{version}.src.tar.gz
BuildArch: noarch
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n) 
# dependencies
Requires: glite-yaim-mpi
Requires: mpi-start
AutoReqProv: yes

%description
A metapackage for glite MPI packages.

%prep
%setup -q

%build

%install
rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root)


%changelog
* Tue Nov 21 2011 Enol Fernandez <enolfc _AT_ ifca.unican.es> - 1.0.1-1%{?dist}
- Spec created to meet Fedora guidelines.
