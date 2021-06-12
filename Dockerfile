FROM rustembedded/cross:armv5te-unknown-linux-musleabi

COPY steps/prequisites.sh /steps/prequisites.sh
RUN /steps/prequisites.sh

COPY steps/libc-musl.sh /steps/libc-musl.sh
RUN /steps/libc-musl.sh

COPY steps/libffi.sh /steps/libffi.sh
RUN /steps/libffi.sh

COPY steps/zlib.sh /steps/zlib.sh
RUN /steps/zlib.sh

COPY steps/ncurses.sh /steps/ncurses.sh
RUN /steps/ncurses.sh

COPY steps/readline.sh /steps/readline.sh
RUN /steps/readline.sh

COPY steps/python.sh /steps/python.sh
RUN /steps/python.sh

COPY steps/python-modules.sh /steps/python-modules.sh
RUN /steps/python-modules.sh

COPY steps/uninstaller.sh /steps/uninstaller.sh
RUN /steps/uninstaller.sh

COPY steps/package.sh /steps/package.sh
