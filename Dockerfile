FROM croservices/cro-http:0.8.0
RUN mkdir /app
COPY . /app
WORKDIR /app
RUN zef install --deps-only . && perl6 -c -Ilib service.p6
ENV VAULT_PERL6_PORT="10000" VAULT_PERL6_HOST="0.0.0.0"
EXPOSE 10000
CMD perl6 -Ilib service.p6
