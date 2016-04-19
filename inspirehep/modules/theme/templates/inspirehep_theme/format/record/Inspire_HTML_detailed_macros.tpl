{#
# This file is part of INSPIRE.
# Copyright (C) 2015, 2016 CERN.
#
# INSPIRE is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 2 of the
# License, or (at your option) any later version.
#
# INSPIRE is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with INSPIRE; if not, write to the Free Software Foundation, Inc.,
# 59 Temple Place, Suite 330, Boston, MA 02111-1307, USA.
#}

{% from "inspirehep_theme/format/record/Inspire_Default_HTML_general_macros.tpl" import render_record_title, record_cite_modal with context %}

{% macro record_collection_heading() %}
  <span id="search-title">Search literature &#62;</span>
  <span id="title">{{ render_record_title() }}</span>
{% endmacro %}

{% macro record_buttons(record) %}
  {% if record.get('arxiv_eprints') %}
    {% if record.get('arxiv_eprints') | is_list() %}
      {% set filtered_arxiv = record.get('arxiv_eprints') %}
      {% for report_number in filtered_arxiv %}
        <a class="btn custom-btn btn-warning pdf-btn no-external-icon" href="http://arxiv.org/pdf/{{ report_number.get('value') | sanitize_arxiv_pdf }}" role="button" title="View PDF">View PDF</a>
      {% endfor %}
    {% endif %}
  {% endif %}
  <a class="btn btn-default dropdown-toggle dropdown-cite cite-btn" type="button" id="dropdownMenu{{record['control_number']}}" data-recid="{{record['control_number']}}"  data-toggle="modal" data-target="#citeModal{{record['control_number']}}">
    <i class="fa fa-quote-right"></i> Cite
  </a>
{% endmacro %}

{% macro record_publication_info(record) %}
  {% set pub_info = record|publication_info %}
  {% if pub_info['pub_info'] %}
    {% if pub_info['pub_info']|length == 1 %}
      Published in <em>{{ pub_info['pub_info'][0] }}</em>
    {% else %}
      Published in <em>{{ pub_info['pub_info']|join(' and ') }}</em>
    {% endif %}
  {% endif %}
  {% if pub_info['conf_info'] %}
    {{ pub_info['conf_info']|safe }}
  {% endif %}
{% endmacro %}

{% macro record_doi(record) %}
  {% set filtered_doi = record.get('dois') | remove_duplicates_from_dict %}
  {% set comma = joiner() %}
  <b>DOI</b>
  {% for value in filtered_doi %}
    {{ comma() }}
    <a href="http://dx.doi.org/{{ value.value | trim | safe}}" title="DOI"> {{ value.value }}</a>
  {% endfor %}
    <br>
{% endmacro %}

{% macro detailed_record_abstract(record) %}
  <div id="record-abstract">
    <div id="record-abstract-title">
      Abstract
    </div>
    {{ record_abstract(record) }}
  </div>
{% endmacro %}

{% macro record_abstract(record) %}
  {% set isAbstractDisplayed = [] %}
  {% if record.get('abstracts') %}
    {% for abstract in record.get('abstracts') %}
      {% if abstract.get('value') and not isAbstractDisplayed %}
        {% if not abstract.get('source') == 'arXiv' %}
          {% do isAbstractDisplayed.append(1) %}
          {{ display_abstract(record, abstract.get('value')) }}
        {% else %}
          {% do isAbstractDisplayed.append(1) %}
          {{ display_abstract(record, abstract.get('value')) }}
        {% endif %}
      {% endif %}
    {% endfor %}
  {% endif %}

  {% if not isAbstractDisplayed %}
    No abstract available for this record.
  {% endif %}
{% endmacro %}

{% macro display_abstract(record, abstract) %}
  {% set number_of_sentences = 2 %}
  <div class="abstract">
    <input type="checkbox" class="read-more-state" id="abstract-input-{{ record.get('control_number') }}" />
    <div class="read-more-wrap">
      {{ abstract | words(number_of_sentences, '. ') }}.
      <span class="read-more-target">
        {{ abstract | words_to_end(number_of_sentences, '. ') }}
      </span>
    </div>
    <label for="abstract-input-{{ record.get('control_number') }}" class="read-more-trigger"></label>
  </div>
{% endmacro %}

{% macro record_keywords(record) %}
  <div id="record-keywords">
    <div id="record-keywords-title">
      Keywords
    </div>
    {% set sep = joiner("; ") %}

    {% if record.thesaurus_terms %}
      {% for keywords in record.thesaurus_terms %}
        {% if (loop.index < 10) %}
          {% if 'keyword' in keywords.keys() %}
            <span class="label label-default label-keyword">
              <a href='/search?p=keyword:"{{ keywords.get('keyword') }}"'>{{ keywords.get('keyword') | trim }}</a>
            </span>
            &nbsp;
          {% endif %}
        {% endif %}
    {% endfor %}

    {% if record.free_keywords or record.thesaurus_terms|length > 10 %}
      <div>
        <a href="" class="text-muted" data-toggle="modal" data-target="#keywordsFull">
          <small>
            Show all {{ record.thesaurus_terms|length }} keywords
            {% if record.get('free_keywords') %}
              plus author supplied keywords
            {% endif %}
          </small>
        </a>
      </div>
      <div class="modal fade" id="keywordsFull" tabindex="-1" role="dialog" aria-labelledby="keywordsFull" aria-hidden="true">
        <div class="modal-dialog">
          <div class="modal-content">
            <div class="modal-header">
              <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
              <h4 class="modal-title" id="keywordsFull">Full list of keywords</h4>
            </div>
            <div class="modal-body">
            <h4>INSPIRE keywords</h4>
              {% if record.get('thesaurus_terms') %}
                {% for keywords in record.get('thesaurus_terms') %}
                  {% if 'keyword' in keywords.keys() %}
                    <span class="label label-default label-keyword">
                      <a href='/search?p=keyword:{{ keywords.get('keyword') }}'>{{ keywords.get('keyword') }}</a>
                    </span>
                    &nbsp;
                  {% endif %}
                {% endfor %}
              {% endif %}

              {% if record.get('free_keywords') %}
                <h4>Author supplied keywords</h4>
                {% for keywords in record.get('free_keywords') %}
                  {% if 'value' in keywords.keys() %}
                    <span class="label label-default label-keyword">
                      <a href='/search?p=keyword:{{ keywords.get('value') }}'>{{ keywords.get('value') }}</a>
                    </span>
                    &nbsp;
                  {% endif %}
                {% endfor %}
              {% endif %}
            </div>
          </div>
        </div>
      </div>
    {% endif %}

    {% else %}
      No keywords available
    {% endif %}
  </div>
{% endmacro%}

{% macro record_links(record) %}
  {% set viewInDisplayed = [] %}
  {% set comma = joiner() %}

  {% if record.get('urls') %}
    {% for url in record.get('urls') %}
      {% if url is not none and url.get('url') | is_external_link and url is mapping %}
        {% if url.get('url') != None %}
          {% set actual_url = url.get('url') %}
          {% set isExternalUrl = actual_url | is_external_link %}
          {% if isExternalUrl and not viewInDisplayed %}
            View in
            {% do viewInDisplayed.append(1) %}
          {% endif %}
          {{ comma() }}
          <a href='{{ actual_url }}'>{{ url.get('description') | weblinks }}</a>
        {% endif %}  
      {% endif %}
    {% endfor %}
  {% endif %}

  {% if record.get('external_system_numbers') %}
    {% for system_number in record.get('external_system_numbers') if system_number.get('obsolete') == False and system_number.get('institute') | is_institute %}
      {% if not viewInDisplayed and not isExternalUrl %}
        View in
        {% do viewInDisplayed.append(1) %}
      {% endif %}

      {% set ads = 'http://adsabs.harvard.edu/abs/' %}
      {% set cds = 'http://cds.cern.ch/record/' %}
      {% set euclid = 'http://projecteuclid.org/' %}
      {% set hal = 'https://hal.archives-ouvertes.fr/' %}
      {% set kek = 'http://www-lib.kek.jp/cgi-bin/img_index?' %}
      {% set msnet = 'http://www.ams.org/mathscinet-getitem?mr=' %}
      {% set zblatt = 'http://www.zentralblatt-math.org/zmath/en/search/?an=' %}
      {% set adsLinked = [] %}

      {% if (system_number.get('institute') | lower) == 'kekscan' %}
        {{ comma() }}
        <a href='{{ kek }}{{system_number.get('value')}}'>
          KEK scanned document
        </a>
      {% elif (system_number.get('institute') | lower) == 'cds' %}
        {{ comma() }}
        <a href='{{ cds }}{{system_number.get('value')}}'>
          CERN Document Server
        </a>
      {% elif (system_number.get('institute') | lower) == 'ads' %}
        {{ comma() }}
        <a href='{{ ads }}{{system_number.get('value')}}'>
          ADS Abstract Service
        </a>
        {% do adsLinked.append(1) %}
      {# HAL: Show only if user is admin - still valid? #}
      {% elif (system_number.get('institute') | lower) == 'hal' %}
        {{ comma() }}
        <a href='{{ hal }}{{system_number.get('value')}}'>
          HAL Archives Ouvertes
        </a>
      {% elif (system_number.get('institute') | lower) == 'msnet' %}
        {{ comma() }}
        <a href='{{ msnet }}{{system_number.get('value')}}'>
          AMS MathSciNet
        </a>
      {% elif (system_number.get('institute') | lower) == 'zblatt' %}
        {{ comma() }}
        <a href='{{ zblatt }}{{system_number.get('value')}}'>
          zbMATH
        </a>
      {% elif (system_number.get('institute') | lower) == 'euclid' %}
        {{ comma() }}
        <a href='{{ euclid }}{{system_number.get('value')}}'>
          Project Euclid
        </a>
      {% endif %}
    {% endfor %}
  {% endif %}

  {# Fallback ADS link via arXiv:e-print #}
  {% if not adsLinked %}
    {% set ads = 'http://adsabs.harvard.edu/abs/' %}
      {% if record.get('arxiv_eprints') | is_list() %}
        {% if not viewInDisplayed %}
          View in
          {% do viewInDisplayed.append(1) %}
        {% endif %}
        {% set filtered_arxiv = record.get('arxiv_eprints') %}
        {% for report_number in filtered_arxiv %}
          {{ comma() }}
          <a href='{{ ads }}{{report_number.get('value')}}'>
            ADS Abstract Service
          </a>
        {% endfor %}
      {% endif %}
    {% endif %}

{% endmacro %}

{% macro record_references(record) %}
  <div class="panel" id="references">
    <div class="panel-heading">
      <div id="record-reference-title">References
        ({{ (record.get('references', '')) | count }})
      </div>
    </div>

    <div class="panel-body">
      <div id="record-references-loading">
        <i class="fa fa-spinner fa-spin fa-lg" ></i><br>Loading references...
      </div>
      <div id="record-references-table-wrapper">
        <table id="record-references-table" class="table table-striped table-bordered" cellspacing="0" width="100%">
        <thead>
            <tr>
                <th>Reference</th>
                <th>Citations</th>
            </tr>
        </thead>
        </table>
      </div>
    </div>

    <div class="panel-footer">
      <!-- <div class="btn-group pull-right">
        <a class="btn btn-default dropdown-toggle" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
        Export {{ (record.get('references', '')) | count }} references <span class="caret"></span>
        </a>
        <ul class="dropdown-menu" id="dropdownMenu{{record['control_number']}}" data-recid="{{record['control_number']}}"  data-toggle="modal" data-target="#citeModal{{record['control_number']}}">
          <li><a class="pointer bibtex" id="bibtex{{record['control_number']}}" data-recid="{{record['control_number']}}">BibTex</a></li>
          <li><a class="pointer latex_eu" id="latex_eu{{record['control_number']}}" data-recid="{{record['control_number']}}">LaTex(EU)</a></li>
          <li><a class="pointer latex_us" id="latex_us{{record['control_number']}}" data-recid="{{record['control_number']}}">LaTex(US)</a></li>
        </ul>
      </div>
      <a class="btn btn-default pull-right" href="/search?p=citedby:{{record['control_number']}}&cc=HEP" data-toggle="modal">View in Search Results</a> -->
    </div>
  </div>
{% endmacro %}

{% macro record_citations(record) %}
  <div class="panel" id="citations">
    <div class="panel-heading">
      <span id="record-citation-title">Citations
        {% if record.get('citation_count', 0) > 0 %}
          ({{ record.get('citation_count', '')  }})
        {% endif %}
      </span>
    </div>

    <div class="panel-body">
      <div id="record-citations-loading">
        <i class="fa fa-spinner fa-spin fa-lg" ></i><br>Loading citations...
      </div>
      <div id="record-citations-table-wrapper">
        <table id="record-citations-table" class="table table-striped table-bordered" cellspacing="0" width="100%">
        <thead>
            <tr>
                <th>Citation</th>
                <th>Citations</th>
            </tr>
        </thead>
        </table>
      </div>
    </div>
    <div class="panel-footer">
      <div class="btn-group pull-right">
        <!-- <a class="btn btn-default dropdown-toggle" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
        Export {{ record.get('citation_count', 0) }} citations <span class="caret"></span>
        </a>
        <ul class="dropdown-menu" id="dropdownMenu{{record['control_number']}}" data-recid="{{record['control_number']}}"  data-toggle="modal" data-target="#citeModal{{record['control_number']}}">
          <li><a class="pointer bibtex" id="bibtex{{record['control_number']}}" data-recid="{{record['control_number']}}">BibTex</a></li>
          <li><a class="pointer latex_eu" id="latex_eu{{record['control_number']}}" data-recid="{{record['control_number']}}">LaTex(EU)</a></li>
          <li><a class="pointer latex_us" id="latex_us{{record['control_number']}}" data-recid="{{record['control_number']}}">LaTex(US)</a></li>
        </ul>
      </div> -->
        {% if record.get('citation_count', 0) > 0  %}
          <a class="btn btn-default pull-right" href="/search?p=refersto:{{record['control_number']}}&cc=HEP">
            {% set citation_count = record.get('citation_count', 0) | show_citations_number %}
          </a>
        {% endif %}
      </div>
    </div>
  </div>
{% endmacro %}

{% macro record_plots(record) %}
  {% set plotExists = [] %}
  {% set plotsCount = [0] %}
  {% if record.urls %}
    {% for url in record.get('urls') %}
       {% if url is not none and url is mapping and url.get('url') is not none %}

          {% if url.get('url').endswith(".png") or url.get('url').endswith(".jpg") %}
            {% do plotExists.append(1) %}
            {# increment plotsCount by 1 #}
            {% if plotsCount.append(plotsCount.pop() + 1) %}{% endif %}
          {% endif %}
      {% endif %}
    {% endfor %}
  {% endif %}

  {% if plotExists %}

    <div id="record-plots">
      <div id="record-plots-title">Plots ({{ plotsCount[0] }})</div>
      <!-- Slider -->
      <div class="row">
        <div class="col-xs-12" id="slider">
          <!-- Top part of the slider -->
          <div class="row">

            <div class="col-md-2 hidden-sm hidden-xs" id="slider-thumbs">
              <!-- Left switcher of slider -->
              <ul class="hide-bullets">
                {% set count = 0 %}
                {% for url in record.get('urls') %}
                   {% if url is not none and url is mapping %}
                    {% if url.get('url').endswith(".png") or url.get('url').endswith(".jpg") %}
                      <li class="col-sm-12 show-plots-thumbnails">
                        <a class="thumbnail" id="carousel-selector-{{ count }}">
                          <img width="100" height="100" src="{{ url.get('url') }}">
                        </a>
                      </li>
                      {% set count = count + 1 %}
                    {% endif %}
                  {% endif %}
                {% endfor %}
              </ul>
            </div>

            <div class="col-md-7 col-xs-12" id="carousel-bounding-box">
              <div class="carousel slide" id="plotsCarousel" data-interval="false">
                <!-- Carousel items -->
                <div class="carousel-inner">
                  {% set count = 0 %}
                  {% for url in record.get('urls')  %}
                    {% if url is not none and url is mapping %}
                      {% if url.get('url').endswith(".png") or url.get('url').endswith(".jpg") %}
                        <div class=" item {% if count == 0 %} active {% endif %}"
                             data-slide-number="{{ count }}">
                          <img src="{{ url.get('url') }}">
                        </div>
                        {% set count = count + 1 %}
                      {% endif %}
                    {% endif %}
                  {% endfor %}
                </div><!-- Carousel nav -->
                <a class="left carousel-control" href="#plotsCarousel" role="button" data-slide="prev">
                  <span class="glyphicon glyphicon-chevron-left"></span>
                </a>
                <a class="right carousel-control" href="#plotsCarousel" role="button" data-slide="next">
                  <span class="glyphicon glyphicon-chevron-right"></span>
                </a>
              </div>
            </div>

            <div class="col-md-3 col-xs-12" id="carousel-text"></div>

            <div id="slide-content" style="display: none;">
              {% set count = 0 %}
              {% for url in record.get('urls') %}
                 {% if url is not none and url is mapping %}
                      {% if url.get('url').endswith(".png") or url.get('url').endswith(".jpg") %}
                         <div id="slide-content-{{ count }}">
                            <span>{{ url.get('description')|strip_leading_number_plot_caption }}</span>
                         </div>
                         {% set count = count + 1 %}
                      {% endif %}
                {% endif %}
              {% endfor %}
            </div>
          </div>
        </div>
      </div><!--/Slider-->
    </div>
  {% endif %}
{% endmacro %}