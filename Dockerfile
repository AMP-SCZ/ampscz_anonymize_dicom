FROM ubuntu:bionic-20200112 as builder

RUN apt-get update \
    && apt-get install -y tk

# miniconda
ENV CONDA_DIR="/opt/miniconda-latest" \
    PATH="/opt/miniconda-latest/bin:$PATH"

RUN apt-get update -qq \
    && apt-get install -y -q --no-install-recommends \
           bzip2 \
           ca-certificates \
           unzip \
           curl \
           git gcc \
    && rm -rf /var/lib/apt/lists/* \

    # Install dependencies.
    && export PATH="/opt/miniconda-latest/bin:$PATH" \
    && echo "Downloading Miniconda installer ..." \
    && conda_installer="/tmp/miniconda.sh" \
    && curl -fsSL -o "$conda_installer" https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh \
    && bash "$conda_installer" -b -p /opt/miniconda-latest \
    && rm -f "$conda_installer" \
    && conda update -yq -nbase conda \

    # Prefer packages in conda-forge
    && conda config --system --prepend channels conda-forge \

    # Packages in lower-priority channels not considered if a package with the same
    # name exists in a higher priority channel. Can dramatically speed up installations.
    # Conda recommends this as a default
    # https://docs.conda.io/projects/conda/en/latest/user-guide/tasks/manage-channels.html
    && conda config --set channel_priority strict \
    && conda config --system --set auto_update_conda false \
    && conda config --system --set show_channel_urls true \
    # Enable `conda activate`
    && conda init bash \
    # Clean up
    && sync && conda clean --all --yes && sync \
    && rm -rf ~/.cache/pip/*

COPY . /opt/ampscz_anonymize_mri
ENV PYTHONPATH="/opt/ampscz_anonymize_mri/ampscz_anonymize_mri:$PYTHONPATH"
ENV PATH="/opt/ampscz_anonymize_mri/scripts:$PATH"
RUN pip install -r /opt/ampscz_anonymize_mri/requirements.txt


