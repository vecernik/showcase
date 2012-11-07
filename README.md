Michal Zeravik Showcase
=======================

This repo contains Javascript/Coffescript/Ruby code samples only for recruiting consideration, there is no runnable or well-documented code.


Widgets
-------
Samples of my web widgets used on websites I was working on.
These are AMD modules based on Dojo Toolkit, but mostly only basic DOM funcionality is used.
The whole collection of these widgets (36 of them) was widely used on websites my team authored.


Admin - Frontend
----------------
Unobtrusive implementation of idea of line in-place website administration.
It's based on idea of cached 'containers' in html identified with ID attribute enlived with ajax and dynamic backend.
Features admin panel, live page SEO editor, setup panel, asset manager (S3 or local), panel editor for invisible attributes


Admin - Model Backend
---------------------
Backend models attached in models/ are common Rails3 creating universal background for storing dynamic editable data.
Configurable container is bind to url, has 1:N Entries that has properties with values, so even designer/coder can create editable content very quickly.
Assets are using Carrierwave with local or Amazon S3 storage.
It is tested working on Heroku and own Apache/Modproxy/Unicorn/Linux setup.
