# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...

Setting Up Gate VPN Server
=================
A StrongSwan based IKEv1 (Cisco) VPN Server accessible via native VPN client.

This also uses NSS to sync users and MFA (using PAM) to authenticate.

Server Setup
------------
Change the attribute/default.rb to suit the needs of the VPN, then run the chef-solo configuration.

<tt>chef-solo -c solo.rb -j solo.json</tt>

Setup PAM URL and token with GATE_URL and GATE_TOKEN environment variable.

Default installation consists of PAM and StrongSwan installation, nss and lib-nss can be added by editing solo.json file. The installed file is located in /usr/local/lib.

Make sure there is no installation of StrongSwan (along with it module, try apt autoremove) in the machine, before starting the chef-solo. Also, compilation of the pam module needs additional -lpam flag to be recognized by StrongSwan charon.

Change the left subnet inside default attributes to split tunnel (left subnet is the tunnelled adress).

Aggressive mode for the VPN is enabled by default.

Client Setup
------------
Mac:
Open System Preferences -> Network. Click the '+' at the lower left side.
Set Interface to 'VPN' and VPN Type to 'Cisco IPSec'. Add your desired VPN name.
Click 'Create'. Set server address and username. Click on Authentication Setting and fill the Pre-Shared Key.
Connect and fill the password.

Android:
Open Settings. Search for VPN. Click on the '+' at the upper right side.
Add desired VPN name. Set Type to IPSec Xauth PSK. Set server address and Pre-Shared Key. Click save. Click the newly created VPN profile to connect.

