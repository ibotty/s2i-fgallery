FROM ibotty/s2i-nginx:latest

MAINTAINER Tobias Florek <tob@butter.sh>

ENV FGALLERY_VERSION 1.8.2

LABEL io.k8s.description="Platform for serving fgallery-based static photo galleries" \
      io.k8s.display-name="fgallery builder ${NGINX_VERSION}" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="builder,fgallery,webserver"

USER 0

# fbida (for exiftran) is from li.nux.ro,
# opencv-* needed for (optional) facedetect,
# jpegoptim, pngcrush and p7zip are optional
RUN rpm -Uvh https://li.nux.ro/download/nux/dextop/el7/x86_64/nux-dextop-release-0-5.el7.nux.noarch.rpm \
 && rpmkeys --import /etc/pki/rpm-gpg/RPM-GPG-KEY-nux.ro \
 && yum install --setopt=tsflags=nodocs -y \
        ImageMagick lcms2-utils zip perl-Image-ExifTool perl-Cpanel-JSON-XS perl-Time-Piece \
        jpegoptim pngcrush p7zip \
        opencv-python opencv-devel \
        fbida \
 && yum clean all -y \
 && curl -LsS https://github.com/wavexx/facedetect/archive/master.tar.gz \
        | tar xzO facedetect-master/facedetect > /usr/local/bin/facedetect \
 && chmod +x /usr/local/bin/facedetect \
 && curl -LsS https://github.com/wavexx/fgallery/archive/fgallery-${FGALLERY_VERSION}.tar.gz \
        | tar xzC /usr/local/share \
 && mv /usr/local/share/fgallery-fgallery-* /usr/local/share/fgallery \
 && ln -fs /usr/local/share/fgallery/fgallery /usr/local/bin

COPY .s2i/bin ${STI_SCRIPTS_PATH}

# overwrite default nginx server config
COPY nginx-fgallery.conf /opt/app-root/etc/nginx.conf.d/default.conf

USER 1001
