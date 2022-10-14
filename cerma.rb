# ======================================================================
# ======================================================================
# ======================================================================
# Copyright "Laboratoire CERMA UMR CNRS/MCC 1563, Thomas LEDUC", 2006-2012
# 	thomas.leduc@cerma.archi.fr
# 
# Ce logiciel est un programme informatique servant a coupler l'outil de 
# simulation Solene avec l'outil d'esquisse architecturale Google SketchUp. 
# 
# Ce logiciel est regi par la licence CeCILL soumise au droit fran\c{c}ais et
# respectant les principes de diffusion des logiciels libres. Vous pouvez
# utiliser, modifier et/ou redistribuer ce programme sous les conditions
# de la licence CeCILL telle que diffusee par le CEA, le CNRS et l'INRIA 
# sur le site "http://www.cecill.info".
# 
# En contrepartie de l'accessibilite au code source et des droits de copie,
# de modification et de redistribution accordes par cette licence, il n'est
# offert aux utilisateurs qu'une garantie limitee.  Pour les memes raisons,
# seule une responsabilite restreinte pese sur l'auteur du programme,  le
# titulaire des droits patrimoniaux et les concedants successifs.
# 
# A cet egard  l'attention de l'utilisateur est attiree sur les risques
# associes au chargement,  a l'utilisation,  a la modification et/ou au
# developpement et a la reproduction du logiciel par l'utilisateur etant 
# donne sa specificite de logiciel libre, qui peut le rendre complexe a 
# manipuler et qui le reserve donc a des developpeurs et des professionnels
# avertis possedant  des  connaissances  informatiques approfondies.  Les
# utilisateurs sont donc invites a charger  et  tester  l'adequation  du
# logiciel a leurs besoins dans des conditions permettant d'assurer la
# securite de leurs systemes et ou de leurs donnees et, plus generalement, 
# a l'utiliser et l'exploiter dans les memes conditions de securite. 
# 
# Le fait que vous puissiez acceder a cet en-tete signifie que vous avez 
# pris connaissance de la licence CeCILL, et que vous en avez accepte les
# termes.
# ======================================================================
# ======================================================================
# ======================================================================
module Constantes
	VERSION = "20140916-1"
	LOCALE = "fr_FR"

	EPSILON = 1.0E-5
	
	FM_SQUARE_INCH_TO_SQUARE_METER = 1.to_m * 1.to_m
	
	# nom du hachage et des clefs du "tronc commun" du paquetage CERMA
	DICT = "CERMA_DICTIONARY"

	# clefs communes a l'ensemble du modele courant
	LBL_DEFAULTPALETTE = "PALETTE::NomPalette"

	LIST_DESC_EDIT = "_liste_des_descripteurs_editables_"
	LBL = "DescripteurEditable::"
	
	# clefs definies au niveau des entites
	LBLFC = "_id_face_et_contour_"
	LBLNORM = "_normale_a_la_face_"

	# constantes en vrac
	FS = " ___ "			# separateur de champs
	NBECHANTILLONS = 10
	DIV_DIAG_BB = 20
	NB_CARACTERES_VCB_VALUE = 17
	
	NOM_PALETTE_PAR_DEFAUT = "grayScale"
end

module Comments
	SHORT_MSG =<<EOF

(c) CERMA, UMR CNRS/MCC 1563, 2006 - 2014

Version #{Constantes::VERSION}
EOF

	NO_IDEA = "Ne sais pas"
	
	INFO_PALETTES =<<EOF
Vous pouvez choisir l'une des palettes suivantes (ou son
inverse en la prefixant par le caractere '-' comme par 
exemple '-grayScale') :

	* niveaux de gris : grayScale,

	* couleurs primaires : red, green, blue

	* divers : fire, ice, rgb332, redGreen.
EOF

end


class Outils
	def self.getAnswer(question, universDesPossibles, msgInfo)
		continue = true
		while (continue)
			tabTmp = UI.inputbox(question, [Comments::NO_IDEA], question.to_s)
			continue = false if (! tabTmp.nil?) and  (! universDesPossibles[tabTmp[0]].nil?)
			UI.messagebox(msgInfo, MB_MULTILINE, "Aide en ligne...") if (continue)
		end
		puts "Answer = #{tabTmp[0]}"
		tabTmp[0]
	end
	
	def self.mkdirRecursif(repertoire)
		unless FileTest.directory?(repertoire)
			mkdirRecursif(File.dirname(repertoire))
			Dir.mkdir(repertoire, 0700)
		end
		repertoire
	end

	def self.rmdirRecursif(repertoire)
		Dir.foreach(repertoire) { |f|
			ffull = "#{repertoire}/#{f}"
			if (f !~ /\.{1,2}$/o)
				if FileTest.directory?(ffull)
					self.rmdirRecursif(ffull)
				else
					File.delete(ffull)
				end
			end				
		}
		Dir.rmdir(repertoire)
	end
	
	def self.compression(msg, level = Zlib::BEST_SPEED)
		#~ en attendant le zlib :
		[msg, false]
		#~ if (msg.length > Constantes::SEUIL_COMPRESSION)
			#~ zbuf = Zlib::Deflate.new(level)
			#~ zmsg = zbuf.deflate(msg, Zlib::FINISH)
			#~ zbuf.close
			#~ [zmsg, true]
		#~ else
			#~ [msg, false]
		#~ end
	end

	def self.decompression(zmsg)
		#~ en attendant le zlib :
		zmesg
		#~ zstream = Zlib::Inflate.new
		#~ msg = zstream.inflate(zmsg)
		#~ zstream.finish
		#~ zstream.close
		#~ msg
	end
	
	#~ def self.md5sum(msg)
		#~ MD5.new(msg).hexdigest.to_s
	#~ end

	#~ def self.md5check(msg, signature)
		#~ if (signature == Outils::md5sum(msg))
			#~ Debug::p("Concordance md5sum")
			#~ true
		#~ else
			#~ Debug::p("BUG :: non concordance md5sum")
			#~ false
		#~ end
	#~ end

	#~ def self.genererIdSession
		#~ Outils::md5sum(rand.to_s + Time.new.to_s)
	#~ end
	
	def self.egalAZero(x)
		(x.abs < Constantes::EPSILON) ? true : false
	end
end


class Debug
	EMERG = 0		# systeme inutilisable
	ALERT = 1		# action a effectuer immediatement
	CRIT = 2		# conditions critiques
	ERR = 3		# conditions d'erreurs
	WARNING = 4	# message d'avertissement
	NOTICE = 5	# normal mais significatif
	INFO = 6		# informations 
	DEBUG = 7		# messages de debugging
	DEFAULT_MESSAGE_LOGLEVEL = DEBUG		# INFO en prod !
	
	def self.p(msg, level = DEBUG)
		if (level <= DEFAULT_MESSAGE_LOGLEVEL)
			#~ STDERR.puts "#{Thread.current} #{Time.new} #{msg}"
			#~ STDERR.puts "#{Thread.current} : #{msg}"
			STDOUT.puts "#{Thread.current} : #{msg}"
		end
	end
end

class Journal
	def initialize(fluxDst, messageDeService)
		@fluxDst = fluxDst
		@messageDeService = messageDeService
		@logs = Array.new
	end

	#~ accesseurs
	def logs=(e)
		@logs.push(e)
	end
	
	def logs
		@logs
	end
	
	#~ methode
	def print
		unless (0 == @logs.length)
			#~ inscription des logs dans le fichier dedie
			fd = File.new(@fluxDst, "w")
			@logs.each { |entree|
				fd.puts(entree)
			}
			fd.close
			
			#~ boite de dialogue d'information
			UI.messagebox(sprintf("%d avertissement(s) enregistre(s):\n%s\nConsultez %s",
				@logs.length,
				@messageDeService,
				@fluxDst)
			)
		end
	end
end

class LireDonnees
	attr_reader :basenameSrc, :contenu
	
	def initialize(param)
		#~ bug relatif aux espaces en debut de fichier - strip contenu ajoute le 11/10/2006
		
		if (param.nil?) or (param.empty?)
			#~ TL le 04/12/2009 - "." remplace par ENV['HOMEPATH']
			param = UI.openpanel("Nom du fichier de donnees", ENV['HOMEPATH'], "")
			if (param.nil?)
				@contenu = @basenameSrc = nil
			else
				@basenameSrc = File.basename(param)
				@contenu = File.read(param).strip
			end
		elsif (FileTest.exists?(param))
			@basenameSrc = File.basename(param)
			@contenu = File.read(param).strip
		else
			@basenameSrc = "TCP_" + rand(10000).to_s
			@contenu = param.strip
		end
	end
end

class Reader
	
	def initialize(nomCompletFluxSrc)
		debut = Time.new
		@modele = Sketchup.active_model

		data = LireDonnees.new(nomCompletFluxSrc)
		basenameSrc = data.basenameSrc
		contenu = data.contenu

		unless (contenu.nil?)
			@tabContenu = contenu.split(/\s+/o)		
			@unitChargementContenu = @tabContenu.size/Constantes::NB_CARACTERES_VCB_VALUE

			if (self.instance_of? ValReader)
				#~ lecture d'un fichier de descripteurs
				tmp = false
				while (not tmp)
					tmp = UI.inputbox(["Nom du descripteur : "], [basenameSrc], "Choix du descripteur")
				end
				@idDesc = tmp[0]
			else
				#~ choix de l'unite de distance pour l'importation
				#~ mm, cm, m, km, inch, feet, yard, mile
				tmp = false
				while (not tmp)
					tmp = UI.inputbox(["Unite des coordonnees : "], ["m"], "Choix de l'unite pour l'import")
				end
				#~ @unit = 1.m
				@unit = eval "1.#{tmp[0]}"
				
				#~ la nouvelle geometrie est importee dans une nouvelle couche
				tabCouches = @modele.layers
				nouvelleCouche = tabCouches.add(basenameSrc)
				nouvelleCouche.visible = true
				@modele.active_layer = nouvelleCouche
				@idDesc = basenameSrc
			end
		
			@ptr = 0
			@geomSkp = @modele.entities

			#~ Sketchup::set_status_text("Fin du chargement, lancement de l'acquisition...", SB_PROMPT);
			@journal = Journal.new("LOGS_#{basenameSrc}.log", "lecture des donnees problematique")
			@modele.start_operation "Lecture des donnees #{basenameSrc}"
			Sketchup::set_status_text("Taux d'acquisition :", SB_VCB_LABEL);
			read
			#~ modele.abort_operation
			@modele.commit_operation
			@journal.print
			printf("Temps d'importation des donnees : %g sec\n", (Time.new - debut).to_f)
			
			if (self.instance_of? ValReader)
				#~ enregistrement prealable du descripteur dans la liste des descripteurs editables
				liste = @modele.get_attribute(Constantes::DICT, Constantes::LIST_DESC_EDIT)
				@modele.set_attribute(
					Constantes::DICT, 
					Constantes::LIST_DESC_EDIT, 
					(liste.nil?) ? @idDesc : liste + Constantes::FS + @idDesc
				)

				#~ avant coloration immediate dans le cas d'une lecture de descripteur (.val)
				ColorerSelonDescripteur.new(@idDesc)
			end
		end
	end

	def read
		#~ methode "generique" (abstraite) a recouvrir par heritage
	end

	def readString
		@ptr += 1
		@tabContenu[@ptr-1]
	end

	def readInt
		readString.to_i
	end

	def readFloat
		readString.to_f
	end
	
	def readVector3D
		[ readFloat, readFloat, readFloat ]
		#~ TL le 05/10/2006 : optimisation - la valeur de la normale n'est pas exploitee !
		#~ @ptr += 3
	end

	def readPoint3D
		#~ demande de DS prise en compte le 04/10/2006
		#~ 1 inch = 0.0254 meter
		#~ [ readFloat, readFloat, readFloat ]
		#~ TL le 04/02/2007 : suite a la saisie de l'unite d'importation
		[ readFloat * @unit, readFloat * @unit, readFloat * @unit ]
	end
end

class Writer
	def initialize(extension)
		#~ TL le 04/12/2009 - "." remplace par ENV['HOMEPATH']
		fluxDst = UI.savepanel("Nom du fichier d'export (sans l'extension)", ENV['HOMEPATH'], "")

		debut = Time.new.to_f
		modele = Sketchup.active_model
		#~ tableau des entites a exporter (toutes par defaut/uniquement la selection)
		entites = (modele.selection.empty?) ? modele.entities : modele.selection
		
		#~ hachage { nom du calque } { tableau des faces du calque }
		hachage = Hash.new
		
		#~ degroupage recursif des divers calques & entites avant export
		modele.start_operation "DegroupageTotal avant export (mode transactionnel)"
		DegroupageTotal.new
		
		entites.each { |entite|
			hachage[entite.layer.name] = [] unless hachage.key?(entite.layer.name)
			case entite.typename
				when 'Face'
					# l'entite courante est une face isolee
					hachage[entite.layer.name].push(entite)
				when 'Group'
					# l'entite courante est un groupe d'entites
					UI.messagebox("Bug au degroupage ('Group' a signaler) !")
					entite.entities.each { |entiteDuGroupe|
						hachage[entite.layer.name].push(entiteDuGroupe) if ('Face' == entiteDuGroupe.typename)
					}
				when 'ComponentInstance'
					# l'entite courante est un Component
					UI.messagebox("Bug au degroupage ('ComponentInstance' a signaler) !")
					entite.entities.each { |entiteDuComponent|
						hachage[entite.layer.name].push(entiteDuComponent) if ('Face' == entiteDuComponent.typename)
					}
			end
		}
		# export a proprement parler
		numeroCalque = 0
		hachage.each_key { |nomCalque|
			#~ @out = File.new(fluxDst + "_" + nomCalque + extension, "w")
			@radicalFichier = fluxDst + "_layer" + numeroCalque.to_s
			@out = File.new(@radicalFichier + extension, "w")
			print(hachage[nomCalque])
			@out.close
			numeroCalque += 1
		}
		#~ annulation du degroupage total
		Sketchup.undo
		printf("Temps d'exportation des donnees : %g sec\n", Time.new.to_f - debut)
	end
	
	def print(hachageCalque)
		#~ methode "generique" a recouvrir par heritage
	end
	
	def nombresContoursEtTrous(face)
		nbContours = 0
		face.loops.each { |anneau|
			nbContours += 1	if (anneau.outer?)
		}
		return [ nbContours, face.loops.length-nbContours ]
	end
end

class ValReader < Reader
	def read
		#~ hachage [ f#_c# ] = valeur de descripteur lue
		@hachage = Hash.new

		nbFacesCir = readInt
		readInt	# lecture du "supNumFaces"
		minDescLu = readFloat
		maxDescLu = readFloat
		(1..nbFacesCir).each {
			_readFace
		}

		@geomSkp.each { |entite|
			if ('Face' == entite.typename)
				entite.set_attribute(
					Constantes::DICT, 
					Constantes::LBL + @idDesc,
					@hachage[ entite.get_attribute(Constantes::DICT, Constantes::LBLFC) ]
				)
			end
		}
		
		@modele.set_attribute(Constantes::DICT, Constantes::LBL + @idDesc + "_min", @minDesc)
		@modele.set_attribute(Constantes::DICT, Constantes::LBL + @idDesc + "_max", @maxDesc)

		if (minDescLu != @minDesc)
			@journal.logs = sprintf("Descripteur %s : minLu = %g, minCalcule = %g\n", @idDesc, minDescLu, @minDesc)
		end

		if (maxDescLu != @maxDesc)
			@journal.logs = sprintf("Descripteur %s : maxLu = %g, maxCalcule = %g\n", @idDesc, maxDescLu, @maxDesc)
		end
	end
	
	def _readFace
		@ptrFace = _readNumeroFace
		nbContours = readInt
		(1..nbContours).each { | ptrCtr|
			_readDescripteur(ptrCtr)
		}
	end
	
	def _readNumeroFace
		begin
			/^f(\d+)$/.match(readString)[1].to_i
		rescue
			@journal.logs = "[lexeme #{@ptr}] Fichier de donnees mal formate (f) !"
		end
	end
	
	def _readDescripteur(ptrCtr)
		#~ restriction au cas particulier de descripteurs numeriques
		#~ tmp = readString
		tmp = readFloat
		if (defined? @minDesc)
			@minDesc = (@minDesc > tmp) ? tmp : @minDesc
			@maxDesc = (@maxDesc < tmp) ? tmp : @maxDesc
		else
			@minDesc = @maxDesc = tmp
		end
		@hachage[ sprintf("f%d_c%d", @ptrFace, ptrCtr) ] = tmp
	end
	
	private :_readFace, :_readNumeroFace, :_readDescripteur
end

class CirReader < Reader
	def read
		nbFacesCir = readInt
		readInt	# lecture du "supNumFaces"
		_readBB
		(1..nbFacesCir).each {
			_readFace
			Sketchup::set_status_text("X"*(@ptr  / @unitChargementContenu), SB_VCB_VALUE);
		}
	end

	def _readBB
		#~ (1..10).each { readString }
		@ptr += 10
	end

	def _readFace
		@ptrFace = _readNumeroFace
		nbContours = readInt
		@normaleLue = Geom::Vector3d.new(readVector3D)
		(1..nbContours).each { |ptrCtr|
			_readContour(ptrCtr)
		}
	end
	
	def _readContour(ptrCtr)
		nbTrous = _readNombreTrous(ptrCtr)
		
		nouvellePolyligne = _readPolyline
		#~ @journal.logs = sprintf("DEBUG : %s\n", nouvellePolyligne.join(" : "))
		begin
			nouvelleFace = @geomSkp.add_face(nouvellePolyligne)
			#~ TODO : inverser le sens de parcours si normale calculee opposee a normale lue
			nouvelleFace.reverse! if (0 > @normaleLue.dot(nouvelleFace.normal))
			
			nouvelleFace.set_attribute(Constantes::DICT, Constantes::LBLFC, sprintf("f%d_c%d", @ptrFace, ptrCtr))
			nouvelleFace.set_attribute(Constantes::DICT, Constantes::LBL + @idDesc, 1)
		rescue
			@journal.logs = sprintf("[f%d_c%d] %d sommets non coplanaires : %s\n", @ptrFace, ptrCtr, nouvellePolyligne.length, 
				_polylineToString(nouvellePolyligne))
			1;
		end
	
		(1..nbTrous).each {
			word = readString;
			unless (/^t$/ =~ word)
				@journal.logs = sprintf("[f%d_c%d] fichier de donnees mal formate '%s' a la place de t !", @ptrFace, ptrCtr, word);
			end
			#~ TL le 20070529 - prise en compte reelle des trous...
			nouvellePolyligne = _readPolyline
			#~ TL le 20120305 - traitement des exceptions
			begin
				nouvelleFaceAEvider = @geomSkp.add_face(nouvellePolyligne)
				@geomSkp.erase_entities nouvelleFaceAEvider
				rescue
					@journal.logs = sprintf("[f%d_c%d] Pb a l'evidement du trou %s\n", @ptrFace, ptrCtr, nouvellePolyligne);
					1;
			end
		}
	end

	def _readNumeroFace
		begin
			word = readString;
			/^f(\d+)$/.match(word)[1].to_i
		rescue
			@journal.logs = sprintf("[f%d - lexeme #{@ptr}] fichier de donnees mal formate '%s' a la place de f !", @ptrFace, word);
			1;
		end
	end

	def _readNombreTrous(ptrCtr)
		begin
			word = readString;
			/^c(\d+)$/.match(word)[1].to_i
		rescue
			@journal.logs = sprintf("[f%d_c%d - lexeme #{@ptr}] fichier de donnees mal formate '%s' a la place de c !", @ptrFace, ptrCtr, word);
			1;
		end
	end

	def _readPolyline
		nbSommets = readInt
		tmp = Array.new
		(1..nbSommets).each { tmp.push(readPoint3D) }
		tmp.pop	# on boucle sur le 1ier sommet dans le format .cir !
		tmp
	end

	def _polylineToString(polyline)
		result = "LINESTRING(";
		polyline.each { |item|
			result += ", " if (11 < result.length);
			result += item.join(" ");
		}
		result += ")";
		result
	end

	private :_readBB, :_readFace, :_readContour, :_readNumeroFace, :_readNombreTrous, :_readPolyline, :_polylineToString
end

class CirWriter < Writer
	BB = "\t99999\t99999\n"*5			# BoundingBox fictive

	def print(facesDuCalque)
		@out.printf("%d\t%d\n#{BB}", facesDuCalque.length.to_s, facesDuCalque.length.to_s)
		i = 0
		facesDuCalque.each { |face|
			card = nombresContoursEtTrous(face)
			@out.printf("f%d %d\n", i+=1, card[0]);
			_printVecteur(face.normal)
			face.loops.each { |anneau|
				entete = (anneau.outer?) ? "c" + card[1].to_s : "t"
				_printAnneau(entete , anneau)
			}
		}
	end
	
	def _printAnneau(entete, anneau)
		@out.printf("%s\n%d\n", entete, 1+anneau.vertices.length)
		anneau.vertices.each { |sommet|
			_printCoordonnees(sommet.position)
		}
		_printCoordonnees(anneau.vertices[0].position)
	end
	
	def _printVecteur(v)
		@out.printf("\t%f\t%f\t%f\n", v.x, v.y, v.z)
	end

	def _printCoordonnees(p)
		#~ FM le 22.09.06 : .to_m : correction bug unites AS/metriques : l'export produisait un 
		#~ fichier cir dans lequel les dimensions etaient x par 40 environ
		@out.printf("\t%f\t%f\t%f\n", p.x.to_m, p.y.to_m, p.z.to_m)
	end
	
	private :_printAnneau, :_printVecteur, :_printCoordonnees
end

# load 'D:/tleduc/prj/sketchUpPlugin/cerma.rb';
# load 'D:/tleduc/prj/sketchUpPlugin/src/io/PythonSalomeWriter.rb';
#~ premiere version le 18.07.2014 
#~ version modifiee le 17.09.2014 pour produire et traiter la veine numerique englobante
class PythonSalomeWriter < Writer
	HEADER = '# ================================================================
# En console PYTHON, depuis SALOME, entrer la commande suivante
#    execfile(r"<repertoire et nom du fichier.py>")
# ================================================================
import salome
salome.salome_init()

import GEOM
from salome.geom import geomBuilder

geompy = geomBuilder.New(salome.myStudy)
gg = salome.ImportComponentGUI("GEOM")

isPlanarWanted = 1
';
	BOTTOM = '
id_allBuildFaces = geompy.addToStudy(allBuildFaces, "All Build Faces")
gg.createAndDisplayGO(id_allBuildFaces)
gg.setDisplayMode(id_allBuildFaces, 1)

geompy.ExportBREP(allFaces, "%s.brep")
';

	def print(facesDuCalque)
		@out.printf(HEADER)
		@cntCtr = 0
		@cntPt = 0
		facesDuCalque.each { |face|
			face.loops.each { |anneau|
				_printAnneau(anneau, anneau.outer?)
			}
		}
		
		question = UI.inputbox( ["Voulez-vous generer une veine numerique englobante dans SALOME ?"], ["oui"], [ "oui|non" ], "Voulez-vous generer une veine numerique englobante dans SALOME ?")
		if (!question || ("oui" != question[0]))
			@out.printf("allFaces = allBuildFaces\n")
		else
			_printVeineNumerique
		end
		
		@out.printf(BOTTOM, File.basename(@radicalFichier))
	end

	def _printAnneau(anneau, isExtCtr)
		@out.printf("\n# create (closed) polyline %d from a list of %d points\n", @cntCtr, anneau.vertices.size);
		
		firstNode = 'pt' + @cntPt.to_s
		str= ''
		anneau.vertices.each { |sommet|
			str += _printCoordonnees(sommet.position) + ', '
		}
		@out.printf("polyline%d = geompy.MakePolyline([%s%s])\n", @cntCtr, str, firstNode)
		@out.printf("# create and add corresponding face\n")
		@out.printf("face%d = geompy.MakeFace(polyline%d, isPlanarWanted)\n", @cntCtr, @cntCtr)

		if (0 == @cntCtr)
			@out.printf("allBuildFaces = face0\n")
		else
			if (isExtCtr)
				@out.printf("allBuildFaces = geompy.MakeFuse(allBuildFaces, face%d)\n", @cntCtr)
			else 
				@out.printf("allBuildFaces = geompy.MakeCut(allBuildFaces, face%d)\n", @cntCtr)
			end
		end
		@cntCtr += 1
	end

	def _printCoordonnees(p)
		#~ FM le 22.09.06 : .to_m : correction bug unites AS/metriques : l'export produisait un 
		#~ fichier cir dans lequel les dimensions etaient x par 40 environ
		idPt = 'pt' + @cntPt.to_s
		@out.printf("%s = geompy.MakeVertex(%f, %f, %f)\n", idPt, p.x.to_m, p.y.to_m, p.z.to_m)
		@cntPt += 1
		return idPt
	end

	def _printVeineNumerique()
		@out.printf("\n# create corresponding Wind Tunnel\n");
		wtNodes = VeineNumerique.new.getWindTunnelNodes
		
		cntWT = 0
		wtNodes.each { |p|
			@out.printf("wt%d = geompy.MakeVertex(%f, %f, %f)\n", cntWT, p.x.to_m, p.y.to_m, p.z.to_m)
			cntWT += 1
		}
		@out.printf("wtGround = geompy.MakePolyline([wt0, wt1, wt2, wt3, wt0])\n")
		@out.printf("wtGroundFace = geompy.MakeFace(wtGround, isPlanarWanted)\n")
		@out.printf("allWTFaces = geompy.MakeCut(wtGroundFace, allBuildFaces)\n\n")

		@out.printf("wtRoof = geompy.MakePolyline([wt4, wt5, wt6, wt7, wt4])\n")
		@out.printf("wtRoofFace = geompy.MakeFace(wtRoof, isPlanarWanted)\n")
		@out.printf("allWTFaces = geompy.MakeFuse(allWTFaces, wtRoofFace)\n\n")

		i = 0
		[ [0, 4, 7, 1], [0, 3, 5, 4], [1, 7, 6, 2], [2, 6, 5, 3] ].each { |idx|
			@out.printf("wtWall%d = geompy.MakePolyline([wt%d, wt%d, wt%d, wt%d, wt%d])\n", i, idx[0], idx[1], idx[2], idx[3], idx[0])
			@out.printf("wtWall%dFace = geompy.MakeFace(wtWall%d, isPlanarWanted)\n", i, i)
			@out.printf("allWTFaces = geompy.MakeFuse(allWTFaces, wtWall%dFace)\n\n", i)
			i += 1
		}

		@out.printf("allBuildFaces = geompy.MakeCut(allBuildFaces, wtGroundFace)\n")
		@out.printf("allFaces = geompy.MakeFuse(allBuildFaces, allWTFaces)\n\n")

		@out.printf("id_allWTFaces = geompy.addToStudy(allWTFaces, 'Wind Tunnel Faces')\n")
		@out.printf("gg.createAndDisplayGO(id_allWTFaces)\n")
		@out.printf("gg.setDisplayMode(id_allWTFaces, 0)\n\n")
	end

	private :_printAnneau, :_printCoordonnees, :_printVeineNumerique
end

#~ modele = Sketchup.active_model
#~ menu = UI.menu("Plugins")
#~ menu.add_item("Export SALOME/Python .py") { PythonSalomeWriter.new('.py') }

class MultipleCirReader
	def initialize
		#~ TL le 04/12/2009 - "." remplace par ENV['HOMEPATH']
		tmp = UI.openpanel("Nom d'un quelconque fichier du repertoire", ENV['HOMEPATH'], "")
		unless tmp.nil?
			repSrc = File.dirname(tmp)
			#~ pour chaque entree du repertoire d'extension .cir, instancier un nouveau CirReader
			Dir.foreach( repSrc ) { |f|
				CirReader.new( "#{repSrc}/#{f}" ) if (f =~ /.cir$/oi)
			}
		end
	end
end

class PrimitivesGeometriques
	#~ maniere de definir une methode de classe :
	def self.isoBarycentre(anneau)
		centre = Geom::Point3d.new
		nbSommets = anneau.vertices.length
		anneau.vertices.each { |sommet|
			centre = sommet.position + centre.to_a
		}
		centre.to_a.map! { |coord| coord /= nbSommets }
	end
end

class SuppressionSelectiveEntites
	def initialize(nomDesc = nil)
		if (nomDesc.nil?)
			nomDesc = UI.inputbox(
				["Type d'entite a supprimer : "],
				[Descripteurs::getEditables],
				"Choix du descripteur"
			)
		end
		
		if nomDesc
			nomDesc = Descripteurs::completion(
				(nomDesc.kind_of?(Array)) ? nomDesc[0] : nomDesc
			)

			modele = Sketchup.active_model
			#~ tableau des entites a exporter (toutes par defaut/uniquement la selection)
			entites = (modele.selection.empty?) ? modele.entities : modele.selection

			entitesADetruire = Array.new
			modele.start_operation("Suppression d'entites du type '#{nomDesc}'")
			entites.each { |entite|
				#~ les 4 instructions suivantes ne fonctionnent pas : pb de synchro ?!
				#~ unless (entite.get_attribute(Constantes::DICT, nomDesc).nil?)
				#~ if (1 == entite.get_attribute(Constantes::DICT, nomDesc))
					#~ entites.erase_entities(entite)
				#~ end
				unless (entite.get_attribute(Constantes::DICT, nomDesc).nil?)
					entitesADetruire.push(entite)
				end
			}
			#~ la suppression se fait en une passe pour supprimer les pb de "synchro"
			entites.erase_entities(entitesADetruire)
		
			#~ modele.abort_operation
			modele.commit_operation
		end
	end
end

class DegroupageTotal
	def initialize
		@modele = Sketchup.active_model
		# tableau des @entites a exporter (toutes par defaut/uniquement la selection)
		#~ @entites = (modele.selection.empty?) ? modele.entities : modele.selection
		#~ TL le 07/12/2005 - modification du degroupage - adaptation de bomb.rb
		#~ _degroupageRecursif(@entites)
		_degroupageComplet
	end
	
	#~ def _degroupageRecursif(entites)
		#~ entites.each { |entite|
			#~ if (entite.kind_of?(Sketchup::ComponentInstance)) or
				#~ (entite.kind_of?(Sketchup::Group)) or (entite.kind_of?(Sketchup::Image))
				#~ _degroupageRecursif(entite.explode)
			#~ end
		#~ }
	#~ end

	def _degroupageComplet
		defList = @modele.definitions
		
		while (_cardinal(defList) > 0)
			defList.each { |d|
				d.instances.each { |e|
					e.explode
				}
			}
		end
	end
	
	def _cardinal(definitionsList)
		card = 0
		definitionsList.each { |d| card += d.count_instances }
		card
	end
	
	#~ private :_degroupageRecursif, :_degroupageComplet, :_cardinal
	private :_degroupageComplet, :_cardinal
end

class InscriptionTextuelleDescripteur
	def initialize
		tmp = UI.inputbox(
			["Nom du descripteur : "],
			[Descripteurs::getEditables],
			"Choix du descripteur"
		)

		if tmp
			nomDesc = Descripteurs::completion(tmp[0])

			modele = Sketchup.active_model
			#~ tableau des entites a exporter (toutes par defaut/uniquement la selection)
			entites = (modele.selection.empty?) ? modele.entities : modele.selection

			modele.start_operation "Inscription de descripteur sur les faces"
			entites.each { |entite|
				if ('Face' == entite.typename)
					entite.loops.each { |anneau|
						etiquette = entite.get_attribute(Constantes::DICT, nomDesc)
						isoBarycentre = PrimitivesGeometriques::isoBarycentre(anneau)
						unless etiquette.nil?
							nouvelleEtiquette = entites.add_text(etiquette.to_s, isoBarycentre)
							nouvelleEtiquette.set_attribute(Constantes::DICT, nomDesc, 1)
						end
					}
				end
			}
			#~ modele.abort_operation
			modele.commit_operation
		end
	end
end

class InscriptionNormale
	def initialize
		modele = Sketchup.active_model
		#~ la taille des normales est un diviseur de la diagonale de la BoundingBox
		tailleNormale = modele.bounds.diagonal / Constantes::DIV_DIAG_BB

		#~ tableau des entites a exporter (toutes par defaut/uniquement la selection)
		entites = (modele.selection.empty?) ? modele.entities : modele.selection

		modele.start_operation "Inscription des normales sur les faces"
		entites.each { |entite|
			if ('Face' == entite.typename)
				normale = entite.normal.to_a
				entite.loops.each { |anneau|
					isoBarycentre = PrimitivesGeometriques::isoBarycentre(anneau)
					extremNorm = [
							isoBarycentre[0] + tailleNormale * normale[0],
							isoBarycentre[1] + tailleNormale * normale[1],
							isoBarycentre[2] + tailleNormale * normale[2]
						]
					if anneau.outer?
						#~ nouvelleNormale = entites.add_line(isoBarycentre, extremNorm)
						nouvelleNormale = entites.add_cline(isoBarycentre, extremNorm)
						nouvelleNormale.set_attribute(Constantes::DICT, Constantes::LBLNORM, 1)
					end
				}
			end
		}
		#~ modele.abort_operation
		modele.commit_operation
	end
end

class ColorerSelonDescripteur
	def initialize(nomDesc = nil)
		#~ choix de la palette de couleurs (si necessaire)
		cfgPalette = ConfigPaletteCouleurs.new
		cfgPalette.set unless cfgPalette.isSet? 
		@myLut = LutLoader.new(cfgPalette.get)

		if (nomDesc.nil?)
			tabTmp = UI.inputbox(
				[ "Nom du descripteur : ", "Nombre d'echantillons" ],
				[ Descripteurs::getEditables, @myLut.size ],
				"Colorer faces selon descripteur"
			)
		else
			tabTmp = UI.inputbox(
				[ sprintf("Nombre d'echantillons (< %d)", @myLut.size) ],
				[ @myLut.size ],
				"Colorer faces selon descripteur"
			)
		end
		
		if tabTmp
			if (nomDesc.nil?)
				nomDesc = Descripteurs::completion(tabTmp[0])
				@nbEchantillons = tabTmp[1].to_i  ### - 1
			else
				nomDesc = Descripteurs::completion(nomDesc)
				@nbEchantillons = tabTmp[0].to_i  ### - 1
			end

			modele = Sketchup.active_model
			#~ tableau des entites a exporter (toutes par defaut/uniquement la selection)
			entites = (modele.selection.empty?) ? modele.entities : modele.selection

			# cas des descripteurs numeriques
			@minDesc = modele.get_attribute(Constantes::DICT, nomDesc + "_min") # .to_f
			@maxDesc = modele.get_attribute(Constantes::DICT, nomDesc + "_max") # .to_f
			@deltaDesc = (@maxDesc - @minDesc) / @nbEchantillons

			modele.start_operation "Coloriage des faces selon descripteur '#{nomDesc}'"
			entites.each { |entite|
				if ('Face' == entite.typename)
					entite.material = _getCouleur(entite.get_attribute(Constantes::DICT, nomDesc)) # .to_f)
				end
			}
			modele.commit_operation
		end
	end
	
	def _getCouleur(valeurDesc)
		@myLut.getColor( ((valeurDesc - @minDesc) / @deltaDesc).to_i )
	end
	
	private :_getCouleur
end

class Descripteurs
	def initialize
		puts "=========================================="
		tab = Sketchup.active_model.attribute_dictionaries[Constantes::DICT]
		unless tab.nil?
			tab.each_pair { |clef, valeur|
				puts "#{clef} = #{valeur}"
			}
		end

		puts "++++++++++++++++++++++++++++++++++++++++++"
		#~ tab = Sketchup.active_model.entities
		#~ unless tab.nil?
			#~ tab.each { |entite|
				#~ ### entite.attribute_dictionaries[Constantes::DICT].each { |x|
				#~ tmp = entite.attribute_dictionaries
				#~ unless tmp.nil?
					#~ tmp.each { |x|
						#~ puts "#{x} = #{x.typename}"
					#~ }
				#~ end
			#~ }
		#~ end
	end
	
	def self.getTabEditables
		Sketchup.active_model.get_attribute(
			Constantes::DICT,
			Constantes::LIST_DESC_EDIT,
			""
		).split(Constantes::FS)
	end
	
	def self.getEditables
		self.getTabEditables.join(", ")
	end
	
	def self.completion(nomDesc)
		self.getTabEditables.each { |id|
			if (id == nomDesc)
				nomDesc = Constantes::LBL + nomDesc
				break
			end
		}
		nomDesc
	end
	
	#~ private :self._getTabEditables
end

class ConfigPaletteCouleurs
	def initialize
		@modele = Sketchup.active_model
	end
	
	def isSet?
		@modele.get_attribute(Constantes::DICT, Constantes::LBL_DEFAULTPALETTE).nil? ?
			false : true
	end

	def set
		rep = Outils::getAnswer(["Nom de palette"], LutLoader::PALETTES, Comments::INFO_PALETTES)
		@modele.set_attribute(Constantes::DICT, Constantes::LBL_DEFAULTPALETTE, rep)
	end
	
	def get
		@modele.get_attribute(Constantes::DICT,
			Constantes::LBL_DEFAULTPALETTE, Constantes::NOM_PALETTE_PAR_DEFAUT)
	end
	
	def writeHtml
		#~ todo
	end	
end

class LutLoader
	attr_reader :colors
	
	PALETTES = {
		"grayScale" => true,		"-grayScale" => true,
		"fire" => true,			"-fire" => true,
		"ice" => true,			"-ice" => true,
		"red" => true,			"-red" => true,
		"green" => true,		"-green" => true,
		"blue" => true,			"-blue" => true,
		"rgb332" => true,		"-rgb332" => true,
		"redGreen" => true,		"-redGreen" => true
	}

	def initialize(colorModel = nil)
		if (colorModel.nil?)
			_grayScale
		elsif (colorModel =~ /^-/o)
			eval "_#{colorModel.sub(/-/,'')}"
			_invert
		else
			eval "_#{colorModel}"
		end
	end
	
	def getColor(i)
		@colors[i]
	end
	
	def size
		@colors.length
	end
	
	def _invert
		@colors.reverse!
	end
	
	def _grayScale
		@colors = Array.new(256, Array.new(3))
		(0..255).each { |i| @colors[i] = [i, i, i] }
	end
	
	def _fire
		#~ import de ImageJ-1.38/ij/plugin/LutLoader.java
		r = [0,0,1,25,49,73,98,122,146,162,173,184,195,207,217,229,240,252,255,255,255,255,255,255,255,255,255,255,255,255,255,255]
                g = [0,0,0,0,0,0,0,0,0,0,0,0,0,14,35,57,79,101,117,133,147,161,175,190,205,219,234,248,255,255,255,255]
                b = [0,61,96,130,165,192,220,227,210,181,151,122,93,64,35,5,0,0,0,0,0,0,0,0,0,0,0,35,98,160,223,255]
		@colors = Array.new(r.length, Array.new(3))
		(0..(r.length-1)).each { |i| @colors[i] = [ r[i], g[i], b[i] ] }
	end
	
	def _ice
		#~ import de ImageJ-1.38/ij/plugin/LutLoader.java
                r = [0,0,0,0,0,0,19,29,50,48,79,112,134,158,186,201,217,229,242,250,250,250,250,251,250,250,250,250,251,251,243,230]
                g = [156,165,176,184,190,196,193,184,171,162,146,125,107,93,81,87,92,97,95,93,93,90,85,69,64,54,47,35,19,0,4,0]
                b = [140,147,158,166,170,176,209,220,234,225,236,246,250,251,250,250,245,230,230,222,202,180,163,142,123,114,106,94,84,64,26,27]
		@colors = Array.new(r.length, Array.new(3))
		(0..(r.length-1)).each { |i| @colors[i] = [ r[i], g[i], b[i] ] }
	end
	
	def _red
		@colors = Array.new(256, Array.new(3))
		(0..255).each { |i| @colors[i] = [ i, 0, 0 ] }
	end

	def _green
		@colors = Array.new(256, Array.new(3))
		(0..255).each { |i| @colors[i] = [ 0, i, 0 ] }
	end
	
	def _blue
		@colors = Array.new(256, Array.new(3))
		(0..255).each { |i| @colors[i] = [ 0, 0, i ] }
	end
	
	def  _rgb332
		#~ import de ImageJ-1.38/ij/plugin/LutLoader.java
		@colors = Array.new(256, Array.new(3))
		(0..255).each { |i| 
			@colors[i] = [ (i&0xe0), ((i<<3)&0xe0), ((i<<6)&0xc0)]
		}
	end

	def _redGreen
		#~ import de ImageJ-1.38/ij/plugin/LutLoader.java
		@colors = Array.new(256, Array.new(3))
		(0..127).each { |i| 
			@colors[i] = [ i*2, 0, 0]
		}
		(128..255).each { |i| 
			@colors[i] = [ 0, i*2, 0]
		}
	end
	
	private :_invert, :_grayScale, :_fire, :_ice, :_red, :_green, :_blue, :_rgb332, :_redGreen
end

class Piquage
	def activate
		puts "Piquage :: Activation"
	end

	def deactivate(view)
		puts "Piquage :: Desactivation"
	end
	
	def onLButtonDown(drapeau, x, y, vue)
		ph = vue.pick_helper
		ph.do_pick x,y
		best = ph.picked_face
		#~ TL le 20070327 : ajout du "unless" dans cas piquage dans le vide...
		afficherInformations(drapeau, x, y, best) unless (best.nil?)
	end
	
	def afficherInformations(drapeau, x, y, face)
		msg = sprintf("%s :: ", 
			face.get_attribute(Constantes::DICT, Constantes::LBLFC)
		)
		Descripteurs::getTabEditables.each { |id|
			msg = sprintf("%s %s = %g, ", msg,
				id, face.get_attribute(Constantes::DICT, Constantes::LBL + id))
		}

		Sketchup::set_status_text(msg)
		puts(msg)
	end
end

class AnalyseMorphologique
	NZ = Geom::Vector3d.new(0, 0, 1)
	
	def initialize
		@modele = Sketchup.active_model
		#~ tableau des entites a analyser (toutes par defaut/uniquement la selection)
		@entites = (@modele.selection.empty?) ? @modele.entities : @modele.selection
	end
	
	def densite
		bbArea = @modele.bounds.height * @modele.bounds.width
		sumArea = 0
		@entites.each { |entite|
			if ('Face' == entite.typename)
				normale = entite.normal.to_a
				sumArea += entite.area if (Outils::egalAZero(entite.plane[3])) and (NZ.parallel?(normale))
			end
		}
		msg = sprintf("%% de bati = %g m2/ %g m2 = %g", 
			sumArea * Constantes::FM_SQUARE_INCH_TO_SQUARE_METER,
			bbArea * Constantes::FM_SQUARE_INCH_TO_SQUARE_METER,
			sumArea/bbArea)
		puts msg
		UI.messagebox(msg)
	end
end

class VeineNumerique
	def initialize
		@modele = Sketchup.active_model
		@bbox = @modele.bounds
	end
	
	def drawFaces
		entites = @modele.entities
		allFaces = getFaces

		if (!allFaces)
			puts 'Nothing to do!'
		else
			@modele.start_operation "Generation de veine numerique"
			#~ create a new layer
			layers = @modele.layers
			windTunnelLayer = layers.add("VeineNumerique")
			windTunnelLayer.visible = true
			@modele.active_layer = windTunnelLayer
				allFaces.each { |face|
				entites.add_face(face)
			}

			#~ @modele.abort_operation
			@modele.commit_operation
		end
	end

	def getWindTunnelNodes
		offsets = _getHtmlSrc
		if (!offsets)
			offsets
		else
			dx0 = offsets[0].to_l
			dx1 = offsets[1].to_l
			dy0 = offsets[2].to_l
			dy1 = offsets[3].to_l
			dz0 = offsets[4].to_l
			dz1 = offsets[5].to_l

			xmin = @bbox.min.x
			xmax = @bbox.max.x
			ymin = @bbox.min.y
			ymax = @bbox.max.y
			zmin = @bbox.min.z
			zmax = @bbox.max.z

			pts = []
			pts[0] = [ xmin-dx0,   ymin-dy0,   zmin-dz0]
			pts[1] = [ xmin-dx0,   ymax+dy1, zmin-dz0]
			pts[2] = [ xmax+dx1, ymax+dy1, zmin-dz0]
			pts[3] = [ xmax+dx1, ymin-dy0,   zmin-dz0]

			pts[4] = [ xmin-dx0,   ymin-dy0,   zmax+dz1]
			pts[5] = [ xmax+dx1,   ymin-dy0, zmax+dz1]
			pts[6] = [ xmax+dx1, ymax+dy1, zmax+dz1]
			pts[7] = [ xmin-dx0, ymax+dy1,   zmax+dz1]

			pts
		end
	end
	
	def getFaces
		pts = getWindTunnelNodes
		if (!pts)
			pts
		else
			[
				[ pts[0], pts[1], pts[2], pts[3] ],
				[ pts[4], pts[5], pts[6], pts[7] ],
				[ pts[0], pts[4], pts[7], pts[1] ],
				[ pts[0], pts[3], pts[5], pts[4] ],
				[ pts[1], pts[7], pts[6], pts[2] ],
				[ pts[2], pts[6], pts[5], pts[3] ]
			]
		end
	end

	#~ def getSalomeRightPrism
		#~ pts = getWindTunnelNodes
		#~ [ pts[0], pts[1], pts[2], pts[3], pts[4] ]
	#~ end

	def _getHtmlSrc
		prompts = [
			"Distance en metre du modele a la veine sur l'axe Ox- (rouge)?",
			"Distance en metre du modele a la veine sur l'axe Ox+ (rouge)?",
			"Distance en metre du modele a la veine sur l'axe Oy- (vert)?",
			"Distance en metre du modele a la veine sur l'axe Oy+ (vert)?",
			"Distance en metre du modele a la veine sur l'axe Oz- (bleu)?",
			"Distance en metre du modele a la veine sur l'axe Oz+ (bleu)?",
		]
		bbdx = @bbox.width
		bbdy = @bbox.height
		bbdz = @bbox.depth
		defaults = [ 
			(2 * bbdx).to_l.to_s,
			(2 * bbdx).to_l.to_s,
			#~ (5 * bbdx).to_l.to_s,
			(2 * bbdy).to_l.to_s,
			(2 * bbdy).to_l.to_s,
			"0",
			(2 * bbdz).to_l.to_s,
			#~ (10 * bbdz).to_l.to_s,
		]
		list = ["", "", "", "", "", ""]
		input = UI.inputbox(prompts, defaults, list, "Distances en metres du modele aux bords de la veine numerique")
		Sketchup::set_status_text("Distance du modele aux bords de la veine " + input.to_s)
		input
	end

	private :_getHtmlSrc
end

class GroundLevelExtractor
	@@NZ = Geom::Vector3d.new(0, 0, 1)
	@@ELEV_LBL = "elevation"
	
	def initialize()
		model = Sketchup.active_model
		
		#~ tableau des entites a traiter (toutes par defaut/uniquement la selection)
		entities = (model.selection.empty?) ? model.entities : model.selection

		model.start_operation "Start GroundLevelExtractor (transactional mode)"

		#~ create a new layer
		layers = model.layers
		groundLevelLayer = layers.add("GroundLevelLayer-" + Time.new.to_s)
		groundLevelLayer.visible = true
		model.active_layer = groundLevelLayer
		count = 0
		entities.each { |entity|
			if ('Face' == entity.typename)
				normal = entity.normal.to_a
				if (Outils::egalAZero(entity.plane[3])) and (@@NZ.parallel?(normal))
					count = count + 1
					entity.layer = groundLevelLayer
					#~ print elevation value on each face
					centre = PrimitivesGeometriques::isoBarycentre(entity.outer_loop)
					label = entities.add_text("0", centre)
					label.set_attribute(Constantes::DICT, @@ELEV_LBL, 1)
				end
			end
		}
		UI.messagebox(sprintf("%d ground faces have been extracted", count))
		model.commit_operation
	end
end

class HorizontalRoofsExtractor
	@@NZ = Geom::Vector3d.new(0, 0, 1)
	@@ELEV_LBL = "elevation"
	
	def initialize()
		model = Sketchup.active_model
		
		#~ tableau des entites a traiter (toutes par defaut/uniquement la selection)
		entities = (model.selection.empty?) ? model.entities : model.selection

		model.start_operation "Start HorizontalRoofsExtractor (transactional mode)"

		#~ create a new layer
		layers = model.layers
		horizontalRoofsLayer = layers.add("HorizontalRoofsLayer-" + Time.new.to_s)
		horizontalRoofsLayer.visible = true
		model.active_layer = horizontalRoofsLayer
		count = 0
		entities.each { |entity|
			if ('Face' == entity.typename)
				normal = entity.normal.to_a
				if (! Outils::egalAZero(entity.plane[3])) and (@@NZ.parallel?(normal))
					count = count + 1
					entity.layer = horizontalRoofsLayer
					#~ print elevation value on each face
					centre = PrimitivesGeometriques::isoBarycentre(entity.outer_loop)
					label = entities.add_text(sprintf("%.1f", centre.z.to_m), centre)
					label.set_attribute(Constantes::DICT, @@ELEV_LBL, 1)
				end
			end
		}
		UI.messagebox(sprintf("%d horizontal roof faces have been extracted", count))
		model.commit_operation
	end
end

class Menu
	def initialize
		modele = Sketchup.active_model
		mainMenu = UI.menu("Plugins")
		menu = mainMenu.add_submenu("plugin CERMA (t4su)")
		menu.add_separator
		menu.add_item("A propos de...") { UI.messagebox(Comments::SHORT_MSG, MB_MULTILINE,'t4su') }
		menu.add_separator
		menu.add_item("Import SOLENE .cir") { CirReader.new('') }
		menu.add_item("Import multiple de .cir") { MultipleCirReader.new() }
		menu.add_item("Import SOLENE .val") { ValReader.new('') }
		menu.add_separator
		menu.add_item("Export SOLENE .cir") { CirWriter.new('.cir') }
		menu.add_item("Export SALOME/Python .py") { PythonSalomeWriter.new('.py') }
		menu.add_separator
		menu.add_item("Generation veine numerique") { VeineNumerique.new.drawFaces }
		menu.add_separator
		menu.add_item("Choix de la palette de couleurs (.cir)") { ConfigPaletteCouleurs.new.set }
		menu.add_item("Colorer les faces (.cir)") { ColorerSelonDescripteur.new }
		menu.add_separator
		menu.add_item("Inscrire descripteur sur les faces (.cir)") { InscriptionTextuelleDescripteur.new }
		menu.add_item("Suppression de l'inscription de descripteur sur les faces (.cir)") { SuppressionSelectiveEntites.new }
		menu.add_separator
		menu.add_item("Inscrire les normales aux faces") { InscriptionNormale.new }
		menu.add_item("Supprimer les normales aux faces") { SuppressionSelectiveEntites.new(Constantes::LBLNORM) }
		menu.add_item("Extraction des sols") { GroundLevelExtractor.new }
		menu.add_item("Extraction des toits terrasses") { HorizontalRoofsExtractor.new }
		menu.add_separator
		menu.add_item("Purger les elements inutilises") {
			modele.start_operation "Purger les elements inutilises (mode transactionnel)";
			modele.definitions.purge_unused;
			modele.commit_operation;	
		}
		menu.add_item("Degroupage recursif") { 
			modele.start_operation "DegroupageTotal (mode transactionnel)";
			DegroupageTotal.new;
			modele.commit_operation;
		}
		menu.add_separator
		menu.add_item("Informations de piquage") { modele.select_tool Piquage.new }
		menu.add_separator
		menu.add_item("Rapport de surfaces") { AnalyseMorphologique.new.densite }
		menu.add_separator
		menu.add_item("Console RUBY") { Sketchup.send_action("showRubyPanel:") }
		#~ subMenu = menu.add_submenu()
	end
end

Menu.new

