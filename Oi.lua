import React, { useState, useEffect } from 'react';
import { Download, Plus, Trash2, FileCode, AlertCircle, CheckCircle, Lightbulb, X } from 'lucide-react';

export default function RobloxLuaEditor() {
  const [scripts, setScripts] = useState([
    { id: 1, name: 'Script1', code: '-- Seu código Lua aqui\nprint("Hello, Roblox!")\n\n-- Exemplo de script:\ngame.Players.PlayerAdded:Connect(function(player)\n    print(player.Name .. " entrou no jogo!")\nend)' }
  ]);
  const [activeScript, setActiveScript] = useState(1);
  const [errors, setErrors] = useState([]);
  const [suggestions, setSuggestions] = useState([]);

  const checkForErrors = (code) => {
    const foundErrors = [];
    const foundSuggestions = [];
    const lines = code.split('\n');

    lines.forEach((line, index) => {
      const lineNum = index + 1;

      // Erros comuns de sintaxe
      if (line.includes('funcion')) {
        foundErrors.push({
          line: lineNum,
          message: 'Erro: "funcion" deve ser "function"',
          fix: line.replace('funcion', 'function')
        });
      }

      if (line.includes('fucntion')) {
        foundErrors.push({
          line: lineNum,
          message: 'Erro: "fucntion" deve ser "function"',
          fix: line.replace('fucntion', 'function')
        });
      }

      if (line.match(/\bif\b/) && !line.includes('then') && !line.trim().endsWith('then')) {
        foundSuggestions.push({
          line: lineNum,
          message: 'Sugestão: "if" deve terminar com "then"',
          fix: line.trim() + ' then'
        });
      }

      if (line.includes('prinnt')) {
        foundErrors.push({
          line: lineNum,
          message: 'Erro: "prinnt" deve ser "print"',
          fix: line.replace('prinnt', 'print')
        });
      }

      if (line.includes('pirnt')) {
        foundErrors.push({
          line: lineNum,
          message: 'Erro: "pirnt" deve ser "print"',
          fix: line.replace('pirnt', 'print')
        });
      }

      if (line.match(/\bfor\b.*\bdo\s*$/)) {
        // for correto
      } else if (line.match(/\bfor\b/) && !line.includes('do')) {
        foundSuggestions.push({
          line: lineNum,
          message: 'Sugestão: loop "for" deve ter "do"',
          fix: line.trim() + ' do'
        });
      }

      if (line.match(/\bwhile\b/) && !line.includes('do')) {
        foundSuggestions.push({
          line: lineNum,
          message: 'Sugestão: loop "while" deve ter "do"',
          fix: line.trim() + ' do'
        });
      }

      if (line.includes('locla')) {
        foundErrors.push({
          line: lineNum,
          message: 'Erro: "locla" deve ser "local"',
          fix: line.replace('locla', 'local')
        });
      }

      if (line.includes('retrun')) {
        foundErrors.push({
          line: lineNum,
          message: 'Erro: "retrun" deve ser "return"',
          fix: line.replace('retrun', 'return')
        });
      }

      if (line.includes('esle')) {
        foundErrors.push({
          line: lineNum,
          message: 'Erro: "esle" deve ser "else"',
          fix: line.replace('esle', 'else')
        });
      }

      if (line.includes('elsefi')) {
        foundErrors.push({
          line: lineNum,
          message: 'Erro: "elsefi" deve ser "elseif"',
          fix: line.replace('elsefi', 'elseif')
        });
      }

      // Parênteses não fechados
      const openParen = (line.match(/\(/g) || []).length;
      const closeParen = (line.match(/\)/g) || []).length;
      if (openParen > closeParen) {
        foundSuggestions.push({
          line: lineNum,
          message: 'Sugestão: Parênteses não fechado',
          fix: line + ')'
        });
      }

      // Aspas não fechadas
      const quotes = (line.match(/"/g) || []).length;
      if (quotes % 2 !== 0) {
        foundSuggestions.push({
          line: lineNum,
          message: 'Sugestão: Aspas não fechadas',
          fix: line + '"'
        });
      }
    });

    setErrors(foundErrors);
    setSuggestions(foundSuggestions);
  };

  const addNewScript = () => {
    const newId = Math.max(...scripts.map(s => s.id), 0) + 1;
    const newScript = {
      id: newId,
      name: `Script${newId}`,
      code: '-- Novo script\nprint("Script criado!")'
    };
    setScripts([...scripts, newScript]);
    setActiveScript(newId);
  };

  const deleteScript = (id) => {
    if (scripts.length === 1) {
      alert('Você precisa ter pelo menos 1 script!');
      return;
    }
    setScripts(scripts.filter(s => s.id !== id));
    if (activeScript === id) {
      setActiveScript(scripts[0].id);
    }
  };

  const updateScriptCode = (id, newCode) => {
    setScripts(scripts.map(s => 
      s.id === id ? { ...s, code: newCode } : s
    ));
    if (id === activeScript) {
      checkForErrors(newCode);
    }
  };

  const updateScriptName = (id, newName) => {
    setScripts(scripts.map(s => 
      s.id === id ? { ...s, name: newName } : s
    ));
  };

  const applyFix = (fix, line) => {
    const currentScript = scripts.find(s => s.id === activeScript);
    const lines = currentScript.code.split('\n');
    lines[line - 1] = fix;
    updateScriptCode(activeScript, lines.join('\n'));
  };

  const autoFixAll = () => {
    let currentScript = scripts.find(s => s.id === activeScript);
    let code = currentScript.code;
    
    errors.forEach(error => {
      const lines = code.split('\n');
      lines[error.line - 1] = error.fix;
      code = lines.join('\n');
    });

    updateScriptCode(activeScript, code);
  };

  const exportToRbxl = () => {
    const xmlContent = `<?xml version="1.0" encoding="UTF-8"?>
<roblox xmlns:xmime="http://www.w3.org/2005/05/xmlmime" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://www.roblox.com/roblox.xsd" version="4">
  <External>null</External>
  <External>nil</External>
  <Item class="Workspace" referent="RBX0">
    <Properties>
      <string name="Name">Workspace</string>
    </Properties>
${scripts.map((script, index) => `    <Item class="Script" referent="RBX${index + 1}">
      <Properties>
        <bool name="Disabled">false</bool>
        <string name="Name">${script.name}</string>
        <ProtectedString name="Source"><![CDATA[${script.code}]]></ProtectedString>
      </Properties>
    </Item>`).join('\n')}
  </Item>
</roblox>`;

    const blob = new Blob([xmlContent], { type: 'application/xml' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = 'game.rbxl';
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    URL.revokeObjectURL(url);
  };

  const currentScript = scripts.find(s => s.id === activeScript);

  useEffect(() => {
    if (currentScript) {
      checkForErrors(currentScript.code);
    }
  }, [activeScript]);

  return (
    <div className="min-h-screen bg-gray-900 text-white flex flex-col">
      {/* Header */}
      <div className="bg-gray-800 border-b border-gray-700 p-3">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-3">
            <FileCode className="w-7 h-7 text-blue-500" />
            <h1 className="text-xl font-bold">Lua Studio Pro - Roblox</h1>
          </div>
          <button
            onClick={exportToRbxl}
            className="flex items-center gap-2 bg-green-600 hover:bg-green-700 px-5 py-2 rounded-lg font-semibold transition-colors"
          >
            <Download className="w-4 h-4" />
            Exportar .rbxl
          </button>
        </div>
      </div>

      <div className="flex flex-1 overflow-hidden">
        {/* Sidebar - Scripts Abertos */}
        <div className="w-56 bg-gray-800 border-r border-gray-700 flex flex-col">
          <div className="p-3 border-b border-gray-700">
            <h2 className="text-sm font-semibold text-gray-400 mb-2">SCRIPTS ABERTOS</h2>
            <button
              onClick={addNewScript}
              className="w-full flex items-center justify-center gap-2 bg-blue-600 hover:bg-blue-700 px-3 py-2 rounded-lg transition-colors text-sm"
            >
              <Plus className="w-4 h-4" />
              Novo Script
            </button>
          </div>
          
          <div className="flex-1 overflow-y-auto p-2">
            {scripts.map(script => (
              <div
                key={script.id}
                className={`group flex items-center justify-between p-2 mb-1 rounded-lg cursor-pointer transition-colors ${
                  activeScript === script.id
                    ? 'bg-blue-600'
                    : 'bg-gray-700 hover:bg-gray-600'
                }`}
                onClick={() => setActiveScript(script.id)}
              >
                <div className="flex items-center gap-2 flex-1 min-w-0">
                  <FileCode className="w-4 h-4 flex-shrink-0" />
                  <input
                    type="text"
                    value={script.name}
                    onChange={(e) => {
                      e.stopPropagation();
                      updateScriptName(script.id, e.target.value);
                    }}
                    onClick={(e) => e.stopPropagation()}
                    className="bg-transparent border-none outline-none text-white text-sm flex-1 min-w-0"
                  />
                </div>
                <button
                  onClick={(e) => {
                    e.stopPropagation();
                    deleteScript(script.id);
                  }}
                  className="opacity-0 group-hover:opacity-100 ml-1 text-red-400 hover:text-red-300 transition-opacity"
                >
                  <X className="w-4 h-4" />
                </button>
              </div>
            ))}
          </div>

          <div className="p-3 border-t border-gray-700 text-xs text-gray-400">
            <div className="flex items-center justify-between mb-1">
              <span>Total:</span>
              <span className="font-semibold text-white">{scripts.length} scripts</span>
            </div>
            <div className="flex items-center justify-between">
              <span>Ativo:</span>
              <span className="font-semibold text-blue-400">{currentScript?.name}</span>
            </div>
          </div>
        </div>

        {/* Editor Principal */}
        <div className="flex-1 flex flex-col min-w-0">
          <div className="bg-gray-800 border-b border-gray-700 px-4 py-2 flex items-center justify-between">
            <div className="flex items-center gap-3">
              <span className="text-sm">
                <span className="text-gray-400">Editando:</span>{' '}
                <span className="text-white font-semibold">{currentScript?.name}</span>
              </span>
              {errors.length === 0 && suggestions.length === 0 && (
                <div className="flex items-center gap-1 text-green-400 text-sm">
                  <CheckCircle className="w-4 h-4" />
                  Sem erros
                </div>
              )}
            </div>
            {errors.length > 0 && (
              <button
                onClick={autoFixAll}
                className="flex items-center gap-2 bg-orange-600 hover:bg-orange-700 px-3 py-1 rounded text-sm transition-colors"
              >
                <AlertCircle className="w-4 h-4" />
                Corrigir Todos ({errors.length})
              </button>
            )}
          </div>
          
          <div className="flex-1 p-0 bg-gray-900 overflow-hidden">
            <textarea
              value={currentScript?.code || ''}
              onChange={(e) => updateScriptCode(activeScript, e.target.value)}
              className="w-full h-full bg-gray-950 text-green-400 p-4 font-mono text-base resize-none focus:outline-none border-none"
              placeholder="-- Escreva seu código Lua aqui..."
              spellCheck="false"
              style={{ 
                lineHeight: '1.6',
                tabSize: 4
              }}
            />
          </div>
        </div>

        {/* Painel de Erros e Sugestões */}
        <div className="w-80 bg-gray-800 border-l border-gray-700 flex flex-col">
          <div className="p-3 border-b border-gray-700">
            <h2 className="text-sm font-semibold text-gray-400">CORRETOR AUTOMÁTICO</h2>
          </div>

          <div className="flex-1 overflow-y-auto p-3 space-y-2">
            {errors.length === 0 && suggestions.length === 0 ? (
              <div className="text-center text-gray-500 mt-8">
                <CheckCircle className="w-12 h-12 mx-auto mb-2 text-green-500" />
                <p className="text-sm">Nenhum erro detectado!</p>
                <p className="text-xs mt-1">Seu código está limpo 🎉</p>
              </div>
            ) : (
              <>
                {errors.map((error, idx) => (
                  <div key={idx} className="bg-red-900/30 border border-red-700 rounded-lg p-3">
                    <div className="flex items-start gap-2 mb-2">
                      <AlertCircle className="w-4 h-4 text-red-400 mt-0.5 flex-shrink-0" />
                      <div className="flex-1 min-w-0">
                        <p className="text-xs text-red-300 font-semibold">Linha {error.line}</p>
                        <p className="text-sm text-red-100 mt-1">{error.message}</p>
                      </div>
                    </div>
                    <button
                      onClick={() => applyFix(error.fix, error.line)}
                      className="w-full bg-red-700 hover:bg-red-600 px-3 py-1.5 rounded text-sm transition-colors"
                    >
                      Corrigir Agora
                    </button>
                  </div>
                ))}

                {suggestions.map((sug, idx) => (
                  <div key={idx} className="bg-yellow-900/30 border border-yellow-700 rounded-lg p-3">
                    <div className="flex items-start gap-2 mb-2">
                      <Lightbulb className="w-4 h-4 text-yellow-400 mt-0.5 flex-shrink-0" />
                      <div className="flex-1 min-w-0">
                        <p className="text-xs text-yellow-300 font-semibold">Linha {sug.line}</p>
                        <p className="text-sm text-yellow-100 mt-1">{sug.message}</p>
                      </div>
                    </div>
                    <button
                      onClick={() => applyFix(sug.fix, sug.line)}
                      className="w-full bg-yellow-700 hover:bg-yellow-600 px-3 py-1.5 rounded text-sm transition-colors"
                    >
                      Aplicar Sugestão
                    </button>
                  </div>
                ))}
              </>
            )}
          </div>

          <div className="p-3 border-t border-gray-700 text-xs text-gray-400">
            <p className="mb-1">💡 <span className="text-white font-semibold">Dica:</span></p>
            <p>O corretor detecta erros comuns automaticamente e sugere correções!</p>
          </div>
        </div>
      </div>
    </div>
  );
}