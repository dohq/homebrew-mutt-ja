require 'formula'

class Mutt < Formula
  homepage 'http://www.mutt.org/'
  url 'https://github.com/dohq/homebrew-mutt-ja/raw/master/mutt-1.5.24.tgz'
  sha1 'a2ad7e3babc63e81c9b0b12e4f6e3377c037918d'

  head do
    url 'http://dev.mutt.org/hg/mutt#default', :using => :hg

    resource 'html' do
      url 'http://dev.mutt.org/doc/manual.html', :using => :nounzip
    end

    depends_on :autoconf
    depends_on :automake
  end

  unless Tab.for_name('signing-party').used_options.include? 'with-rename-pgpring'
    conflicts_with 'signing-party',
      :because => 'mutt installs a private copy of pgpring'
  end

  conflicts_with 'tin',
    :because => 'both install mmdf.5 and mbox.5 man pages'

  option "with-debug", "Build with debug option enabled"

  depends_on 'openssl'
  depends_on 'tokyo-cabinet'
  depends_on 'libidn'
  depends_on 's-lang'
  depends_on 'gpgme'
  depends_on 'w3m'

  def install
    args = ["--disable-dependency-tracking",
            "--disable-warnings",
            "--prefix=#{prefix}",
            "--with-ssl=#{Formula['openssl'].opt_prefix}",
            "--with-sasl",
            "--with-gss",
            "--enable-imap",
            "--enable-smtp",
            "--enable-pop",
            "--enable-hcache",
            "--with-tokyocabinet",
            "--with-curses",
            "--with-regex",
            "--with-idn",
            "--enable-cjk-ambiguous-width",
            "--with-slang",
            "--enable-gpgme",
            # This is just a trick to keep 'make install' from trying to chgrp
            # the mutt_dotlock file (which we can't do if we're running as an
            # unpriviledged user)
            "--with-homespool=.mbox"]

    if build.with? 'debug'
      args << "--enable-debug"
    else
      args << "--disable-debug"
    end

    if build.head?
      system "./prepare", *args
    else
      system "./configure", *args
    end
    system "make"
    system "make", "install"

    (share/'doc/mutt').install resource('html') if build.head?
  end
end
