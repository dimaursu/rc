# encoding: utf-8
require 'yaml'
require 'debugger'

def max_pdv(pdv_hash)
  debugger
  pdv_hash
end

class Retea
  def initialize(statii,pdv,pvv)
    # aceștia sunt parametrii maximi ai rețelei
    @m_statii = statii
    @m_pdv = pdv
    @m_pvv = pvv
    # elementele rețelei
    @pcabluri, @statii, @concetratoare, @cabluri = [], [], [], []
    # @pcabluri - proprietățile cablurilor
    self.adauga_concentratoarele
    self.uneste_cablurile
    self.adauga_statiile
  end

  def autoverifica
    ## Toate erorile sunt critice. Rețeaua nu poate funcționa dacă unul din
    # parametri nu e respectat. Din acest motiv, nu facem rescue la nici o
    # excepție.
    if @statii.length > @m_statii
      raise "Prea multe stații în rețea"
    elsif self.pdv > @m_pdv
      raise "Path Delay Value e prea mare. Mai taie din cablu"
    elsif self.pvv > @m_pvv
      raise "Path Variability Value e prea mare. Rărește din concentratoare"
    end
  end

  def pdv
    ## Algoritmul de calculare a PDV
    # parcurgem graful în toate direcțiile, stocând într-un tabel valorile la
    # fiecare parcugere. Returnăm cel mai mare element al tabelului
    # Pentru simplitate vom considera că:
    # 1. Concentratoarele au o singură legătură între ele
    # 2. Concentratoarele nu vor forma bucle
    # 3. Fiecare concentrator are 3 stații
    costuri = {}
    @concentratoare.each do |cc|
      cablu = @cabluri[cc[1]["ac_cablu"]]
      retinerea_cc = nil
      # există concentratoare fără al 2-lea fir. ^ sus resetăm retinerea_cc
      # (reținerea pe concentrator) și mai jos verficăm dacă avem un așa cablu.
      if cablu
        prp = @pcabluri[cablu["tip"]]
        raise "Cablu #{cc[1]["ac_cablu"]} este prea lung" if cablu["lungime"] > prp["l_max"]
        retinerea_cc = cablu["lungime"] * prp["retinerea"] + prp["baza_im"]
      end

      cc[1]["statii"].each do |statie|
        cablu = @cabluri[statie]
        prp = @pcabluri[cablu["tip"]]
        # verficăm lungimea cablului
        raise "Cablu #{statie} este prea lung" if cablu["lungime"] > prp["l_max"]
        retinerea_pe_lungime = cablu["lungime"] * prp["retinerea"]
        costuri[cc[0]] = [retinerea_pe_lungime + prp["baza_st"],
                          retinerea_pe_lungime + prp["baza_im"],
                          retinerea_pe_lungime + prp["baza_dr"]]
      end
      # adăugăm la array ca al 3-lea element PDV-ul dintre concentrator
      costuri[cc[0]][3] = { cc[1]["alt_concentrator"] => retinerea_cc }
    end
    puts costuri
    return max_pdv(costuri)
  end

  def pvv
    ## Algoritmul de calculare a PVV
    # Nu contează lungimea cablurilor, doar concentratoarele
    # Considerăm pe rînd fiecare
  end

  def adauga_statiile
    # itereaza prin concentratoare
    @concentratoare.each {|cc| @statii << cc[1]['statii']}
    @statii.flatten!
  end

  def adauga_concentratoarele
    @concentratoare = YAML::load(File.open("concentratoare.yml", "r"))
  end

  def uneste_cablurile
    @cabluri = YAML::load(File.open("cabluri.yml", "r"))
    @pcabluri = YAML::load(File.open("proprietati-cabluri.yml", "r"))
  end
end

