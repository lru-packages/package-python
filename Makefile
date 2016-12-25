EPOCH=1
ITERATION=1
PREFIX=/usr/local
LICENSE=Python-2.0
VENDOR="The Python Software Foundation"
MAINTAINER="Ryan Parman"
DESCRIPTION="An interpreted, interactive, object-oriented programming language."
URL=https://python.org
RHEL=$(shell rpm -q --queryformat '%{VERSION}' centos-release)

#-------------------------------------------------------------------------------

all:
	@echo "Run either 'make python27' or 'make python3'."

#-------------------------------------------------------------------------------

.PHONY: python27
python27: python27-vars info compile27 install-tmp package move

.PHONY: python3
python3: python3-vars info compile3 install-tmp package move

#-------------------------------------------------------------------------------

.PHONY: python27-vars
python27-vars:
	$(eval NAME=python27)
	$(eval VERSION=2.7.13)
	$(eval BINARY=python2.7)

.PHONY: python3-vars
python3-vars:
	$(eval NAME=python3)
	$(eval VERSION=3.5.2)
	$(eval BINARY=python3.5)

#-------------------------------------------------------------------------------

.PHONY: info
info:
	@ echo "NAME:        $(NAME)"
	@ echo "VERSION:     $(VERSION)"
	@ echo "ITERATION:   $(ITERATION)"
	@ echo "PREFIX:      $(PREFIX)"
	@ echo "LICENSE:     $(LICENSE)"
	@ echo "VENDOR:      $(VENDOR)"
	@ echo "MAINTAINER:  $(MAINTAINER)"
	@ echo "DESCRIPTION: $(DESCRIPTION)"
	@ echo "URL:         $(URL)"
	@ echo "RHEL:        $(RHEL)"
	@ echo "BINARY:      $(BINARY)"
	@ echo " "

#-------------------------------------------------------------------------------

.PHONY: clean
clean:
	rm -Rf /tmp/installdir* python*.rpm Py* gmon.out

#-------------------------------------------------------------------------------

.PHONY: install-deps
install-deps:
	yum -y install \
		wget \
		bzip2-devel \
		ncurses-devel \
		openssl-devel \
		sqlite-devel \
		zlib-devel \
		valgrind-devel \
		tcl-devel \
		lzma-devel \
		gdbm-devel \
	;

#-------------------------------------------------------------------------------

.PHONY: compile27
compile27:
	wget https://www.python.org/ftp/python/$(VERSION)/Python-$(VERSION).tar.xz;
	tar xf Python-$(VERSION).tar.xz;
	cd ./Python-$(VERSION) && \
		./configure --prefix=$(PREFIX) \
			--enable-profiling \
			--enable-ipv6 \
			--enable-unicode=ucs4 \
			--with-valgrind \
			--with-ensurepip=yes && \
		make;

.PHONY: compile3
compile3:
	wget https://www.python.org/ftp/python/$(VERSION)/Python-$(VERSION).tar.xz;
	tar xf Python-$(VERSION).tar.xz;
	cd ./Python-$(VERSION) && \
		./configure --prefix=$(PREFIX) \
			--enable-shared \
			--enable-profiling \
			--enable-loadable-sqlite-extensions \
			--enable-ipv6 \
			--enable-big-digits=30 \
			--with-hash-algorithm=siphash24 \
			--with-signal-module \
			--with-valgrind \
			--with-threads \
			--with-doc-strings \
			--with-tsc \
			--with-pymalloc \
			--with-ensurepip=yes && \
		make;

#-------------------------------------------------------------------------------

.PHONY: install-tmp
install-tmp:
	mkdir -p /tmp/installdir-$(NAME)-$(VERSION);
	cd ./Python-$(VERSION) && \
		make altinstall DESTDIR=/tmp/installdir-$(NAME)-$(VERSION);

#-------------------------------------------------------------------------------

.PHONY: package
package:

	# Main package
	fpm \
		-f \
		-d "$(NAME)-libs = $(EPOCH):$(VERSION)-$(ITERATION).el$(RHEL)" \
		-s dir \
		-t rpm \
		-n $(NAME) \
		-v $(VERSION) \
		-C /tmp/installdir-$(NAME)-$(VERSION) \
		-m $(MAINTAINER) \
		--epoch $(EPOCH) \
		--iteration $(ITERATION) \
		--license $(LICENSE) \
		--vendor $(VENDOR) \
		--prefix / \
		--url $(URL) \
		--description $(DESCRIPTION) \
		--rpm-defattrdir 0755 \
		--rpm-digest md5 \
		--rpm-compression gzip \
		--rpm-os linux \
		--rpm-changelog CHANGELOG-$(NAME).txt \
		--rpm-dist el$(RHEL) \
		--rpm-auto-add-directories \
		usr/local/bin \
	;

	# Libs package
	fpm \
		-f \
		-s dir \
		-t rpm \
		-n $(NAME)-libs \
		-v $(VERSION) \
		-C /tmp/installdir-$(NAME)-$(VERSION) \
		-m $(MAINTAINER) \
		--epoch $(EPOCH) \
		--iteration $(ITERATION) \
		--license $(LICENSE) \
		--vendor $(VENDOR) \
		--prefix / \
		--url $(URL) \
		--description $(DESCRIPTION) \
		--rpm-defattrdir 0755 \
		--rpm-digest md5 \
		--rpm-compression gzip \
		--rpm-os linux \
		--rpm-changelog CHANGELOG-$(NAME).txt \
		--rpm-dist el$(RHEL) \
		--rpm-auto-add-directories \
		--after-install after-install-libs.sh \
		usr/local/lib \
	;

	# Development package
	fpm \
		-f \
		-d "$(NAME) = $(EPOCH):$(VERSION)-$(ITERATION).el$(RHEL)" \
		-s dir \
		-t rpm \
		-n $(NAME)-devel \
		-v $(VERSION) \
		-C /tmp/installdir-$(NAME)-$(VERSION) \
		-m $(MAINTAINER) \
		--epoch 1 \
		--iteration $(ITERATION) \
		--license $(LICENSE) \
		--vendor $(VENDOR) \
		--prefix / \
		--url $(URL) \
		--description $(DESCRIPTION) \
		--rpm-defattrdir 0755 \
		--rpm-digest md5 \
		--rpm-compression gzip \
		--rpm-os linux \
		--rpm-changelog CHANGELOG-$(NAME).txt \
		--rpm-dist el$(RHEL) \
		--rpm-auto-add-directories \
		usr/local/include \
	;

	# Documentation package
	fpm \
		-f \
		-d "$(NAME) = $(EPOCH):$(VERSION)-$(ITERATION).el$(RHEL)" \
		-s dir \
		-t rpm \
		-n $(NAME)-doc \
		-v $(VERSION) \
		-C /tmp/installdir-$(NAME)-$(VERSION) \
		-m $(MAINTAINER) \
		--epoch 1 \
		--iteration $(ITERATION) \
		--license $(LICENSE) \
		--vendor $(VENDOR) \
		--prefix / \
		--url $(URL) \
		--description $(DESCRIPTION) \
		--rpm-defattrdir 0755 \
		--rpm-digest md5 \
		--rpm-compression gzip \
		--rpm-os linux \
		--rpm-changelog CHANGELOG-$(NAME).txt \
		--rpm-dist el$(RHEL) \
		--rpm-auto-add-directories \
		usr/local/share \
	;

#-------------------------------------------------------------------------------

.PHONY: move
move:
	mv *.rpm /vagrant/repo
