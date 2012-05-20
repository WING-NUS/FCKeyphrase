CREATE TABLE IF NOT EXISTS `documents` (
  `id` int(11) NOT NULL auto_increment,
  `doi` varchar(255) collate utf8_unicode_ci default NULL,
  `keyphrases` text collate utf8_unicode_ci,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
create index doi_index on documents(doi);
