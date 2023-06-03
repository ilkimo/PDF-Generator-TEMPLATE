FROM nanozoo/pdflatex:3.14159265--f2f4a3f

# Set the working directory
WORKDIR /usr/src/latex-generator

# Copy only the Makefile into the container
COPY Makefile .

# Copy the example files into the container
COPY example/ /usr/src/latex-generator/example/

# Set the command to be run when the container starts
ENTRYPOINT ["make"]
CMD ["all"]
