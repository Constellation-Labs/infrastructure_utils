#!/usr/bin/env bash

blu='\033[1;36m'
clr='\033[0m'

echo "$${blu}[Tessellation]$${clr} Setting up user_data"

mkdir -p /tmp/l0
chown ${user}:${user} /tmp/l0
mkdir -p /tmp/l1
chown ${user}:${user} /tmp/l1

mkdir -p --mode 0700 /home/${user}/.ssh
touch /home/${user}/.ssh/authorized_keys
#Team keys
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCoaQ4GycMaxDjebYpWBEBZGMYE5NmXLQnDaYr08GKYZ0ogzrNdEM7r3ct0WXQnRTvtwSUfz2UYMeot0HlyZSumdQRPCIscBcNfghfjyfXE9cjOcI1ORXyGB456z5JS/tpfwuQxaMTqKqRijIiMURQIFkn0AeDl+hTby+Bocdw76PMRJJVxy3oGheOztWKkA2bTCVe7to1euYhRHt2L1wNMqZ8wHtjEXCBRRYCPm44+qXDWn4zpOsTz1GZj5cV/HOhK4rUaOkid9tkczShwVH9rCME6bS52E+q5CJWtVUbctFTkZWEKNSd5NCVLTgz+aG/ufg/tr+aXHE1BnmayBrArzpHFZlEGVHc3+P807sd83Xy5EOxeorca9DYHOjsqlIsnuZPe6VJ5rhfTOfKFwYlCadRkKR1zYuJJkKHg9MU8TdELx4tFB+I4PlUQq7n9kFC2NNZ4ejsWJN7MY0/yDlksTJJlTI08B2m34umVRYozw7geV3tKvb3+b1zjUuyrCBaKzMVk6qubVdwrPGhH9XURMtPic/Z5QqmDdw2Ukbd40UFd46x2TaJN69dN4YkK+oRfl3oNibC2QaI9563lOdGQ6Ffgj+kyAJad7lUD2Nz95jYsdG6Cp/2nxqRAWN4sjvp6u5MPTlFI+e095opZaR6Q7p2EUX59NalPzB6FQr4JeQ== kpudlik"  >> /home/${user}/.ssh/authorized_keys
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCHqoBzuWzQ4YOJGE/rXdFmH+2rjLh9d6es6GSEK/+mnAvORLMaB57vY7GvIdWjgOW/V/x5K6QNN5aqDUCYFbqv+HSzJsU/TgdGxmeYqcEp6y1UIldn8H8fTlxNBI/uO6EwQpxQHj3dSelCMVg8g7mIR1/Gbx6t3bByAIOyQMYfvpJH5Q6m4KLXdrplkOTPMRSH0N2aDo0rt/K9JOWl3LGN5uAjsEFNeXUyj+9d+tpxhUqB2zNZPiXDngEX0F/baiMlwrvFcrvS0cgCZ5GmFBKsEg1XYU0C3tz+lbQHEgdIpowDef8Dp6lO+p4DbV2LzMa8WyM6ZQcqLveS2sodZNIH cl-dmuskat"  >> /home/${user}/.ssh/authorized_keys
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDIRZF1pMb4XUhmB+pqLLraHCSPv+yW731rE51yF3gRDiBl7SEDyzLAnBWn99kUuBLJzJML3iEqZYj1PyzkDH5UNQWmk57lolLAV0/9m+NJlD6sUevH8/n9xNJ+rzlRLJS0p2XcTfuinPXicmPBo5QHOPab4UVGc8s4CI1KjyGYmSfGfXgrQzvxPJN7Y7oEW1X8KAB7F+HcGZAEz2BO6W7ya1FCVTn+07qCIZGUHsUhOMradcrCsA+B1zpebAIq0Ilz/imbHJXkjeB0g2wfdCFMi9XqbGUC20TRJQ1+ScrnC+aycX6iIvubk/k+xQ3hg87vSQPyFC0nKc5rrxOcduWd Alex"  >> /home/${user}/.ssh/authorized_keys
echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMkNLjrCOWXi2rDzZOQ4swAUF0Org4WCWO6tWJJPPOdp Krystian"  >> /home/${user}/.ssh/authorized_keys
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDuv40fdWOq9h6axo3x4KXJMxvukVFbwUzb+5fvZ2GWKTDjamDOChNx1PF+MfGP30ooxyT+//Ep3vjNDpNbFEqMwCwxb7ehtg76PYtNMc1Ic4xiOfcKiDTl2+ljZxo5IbNgvMc2lZh1mH3uz9lLynRBwLOJjnfVQJmDIqkFgbmxEv30gEZBTEIvSgBup5FnIH23ZSrSEOvNc9+w595SxSI7jCmPafe+U0Uazy4mnA0gVKUjlz3KlXuLfapEyrHhyzqirqgVsk+QRCZUnxHZAxT4mTqGlFRv4HsHoW1nIzq+NV7nnCPQ5HqwbzsrPb0LYwY2oWPzAvn5Fy+ZXmjzUMul327ePcki/c/PoVsvrywSO9t/1ePPs+gb294q5Qu4gUR7fGdpwsFUBWhEdibt/n7OgSau8OGDah/IdhZPuWGmqphOvYrXzb3f4PTJJbpAPKeknsZAWGUaYKNIWnqyeZREDxVyDqrhTBq1xuUlNfFg9AsoU0Jc6w2bjj7pLMIiIZaAmO9kczZaQTFgF6ai3t6OsZ20hvZzrZ4cwRAOWV/Zusv76SiqUwoQdij2awT71ppQPqh9W3RguV+fQgNZuFW0DmqvLs9Ngkg8XjETE1M9fu7O+5dBMuxzDqFB2TWvfE2UkxSXV9PNcqzYwhuCH9/x8V1RjLoRocmN9GwZA9GWCQ== Marcin1"  >> /home/${user}/.ssh/authorized_keys
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDb6+HQ2Q7zF2gchJZY0Ys1Q9q38xn8h/XJXFfxPyREeMuHr3lialiksDkfeXFtDl6DIzuiabCeFH8fJjfErHFZL82V9QiXmXqBov60DuTl1yWm8S2PN1Nf8ytoMnElqfOx+6Trk4QnbBVbgWt/d3BiUr3rZPSxEjgJjSTsEvbQSBqytwIWZIZF380wy1520rvRb6DsL/JfMDKcyh/NKtwa+P8gaIlSR0OqRJD2zDLr4S1x0SaAYY4cfJ0XohjqqcYSJ9MWD9RblOsi91SdO6rKrAG0gRKROn57oCicUYiitq38O6X5BqoEoV0201b4cwIo6VzkYSyI8DgFD3cwn5aJ Marcin2"  >> /home/${user}/.ssh/authorized_keys
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC5xHJlgR+XAdzkLLj2K7+bcbqQwW+H8IOgBL60btlrrSs6SiQynNtDOdCVaOHHiAunDrLCW65YdNL62yDYaNWPYlTPsLBakWsAwha7p1r105WCef60NnZXg56raG6riyMZ9t2Tx7pN4LonYVygp3vaoBf9wuLVi5VV+MkCS5nTDK5IfPNln304YYARL6bXvKsiTbAH2dC1NldI0gZeppdvtlAZDSTAMhY6BHAVBHchTkYvAmlXgau+cNb6gyuzUoWqrnzLkVpNpTdLs6wLlDO60JHOr4XRUn0ZAtQaXC+9KGw9y5qUR99ePYugvgqOqQ5FiW7mIt5BBa9N7VKZb3SaeUM1izCkMCs7fSua/UgAho39siuchOGy7SHLYuPXKHi1tVsgnjloFDMMmAOB2ztUC3g9N1//RxR1AsR1ANKgEoOVHgmAUK24G1Xz1tgUUI5SCsDNI+4iJ8QS0aLQh3SLfZHthDSk+xQ6ovXJV9KZMgtTpIv9KH8zNaOgAdt6zrM= Marcus"  >> /home/${user}/.ssh/authorized_keys
echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINb++0IXZ8130JaqJYBzJDPN/yFjYvHUaLhQWGn55Y+c Ryle"  >> /home/${user}/.ssh/authorized_keys
echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICEhYRNdZFLK+SxEda4EcGinw1kGfOoRomOQ1Ja2vzyX james@constellationnetwork.io"  >> /home/${user}/.ssh/authorized_keys

#Monitoring Service Key
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCS7CTYxWHnOw/6ubXUCa0R9+xFrVuxaRODcrvQeozzCgYwjR6bkEWi3HGmP6MUGFSrfWLazoMdQI/lH9o/kFefyQfHb4OMuIuMdzfxl/9aLX6RT445Ur7nLPO1ciGz9FkhZuuaDcyqVr3FNPiHmlDeKCRKfXEqKVCPJ5nkxgHZxN4S79uK771nUrRYUaekoLI13dtbZncP2dqf/VkoHL0YPvY0BDftFcLoGqu/RGrNJNUx9Ggxx2V5zTomiKeO4R43JrlCqCFGLRlSa8ljv4KPb2+31IAaU1AFU1z1NzXjBiTjeCxKl6dQVH6bk9+AkSpX8Vap4el1KjHrwyeO1brb ubuntu@ip-172-31-10-4"  >> /home/${user}/.ssh/authorized_keys

chown ${user}:${user} /home/${user}/.ssh/authorized_keys
chmod 0600 /home/${user}/.ssh/authorized_keys
